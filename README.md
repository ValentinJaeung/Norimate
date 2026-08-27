# Norimate

SO-ARM100 **양팔(bimanual)** 텔레오퍼레이션 기반 imitation learning 데이터 수집 파이프라인.
ROS 없이 [LeRobot](https://github.com/huggingface/lerobot)로 카메라 연동·캘리브레이션·텔레오퍼레이션·데이터 수집을 구성하고,
**3구 풋페달**로 에피소드 수집을 손 안 대고 제어한다.

---

## 아키텍처

```
   리더 팔 x2 (좌/우) ──► 사람이 조작
        │ 관절값 미러링
        ▼
   팔로워 팔 x2 (좌/우) ──► 실제 동작
        │
   카메라 3대 ──► 손목 UVC x2 + 상단 RealSense x1 (RGB + Depth)
        │
        ▼
   lerobot-record ──► LeRobotDataset (에피소드별 저장)
        ▲
        │ n / r / q  (키 입력)
   pedal_bridge.py ──► 풋페달을 디바운스해서 키로 변환
```

수집 중 에피소드 제어는 LeRobot record의 기본 단축키(→/←/ESC = n/r/q)를 그대로 쓴다.
페달은 이 키를 대신 눌러주는 장치일 뿐이라 **LeRobot 내부는 건드리지 않는다.**

### 페달 매핑

| 페달 | 동작 | 보내는 키 (LeRobot) |
|------|------|--------------------|
| 왼쪽 | 현재 에피소드 **재수집** | `r` (←) |
| 중앙 | 수집 **종료** · 인코딩 · 저장 | `q` (ESC) — *오작동 방지용 hold-to-confirm* |
| 오른쪽 | 저장 후 **다음 에피소드** | `n` (→) |

---

## 하드웨어

- 팔로워 SO-ARM100 x2 (좌/우), 리더 SO-ARM100 x2 (좌/우)
- 손목 카메라: UVC x2 (팔당 1대)
- 상단 카메라: Intel RealSense x1 (RGB + Depth)
- 3구 USB 풋페달 (PCsensor 계열 권장, HID 키보드로 인식되는 프로그래머블 모델)

> **환경:** Ubuntu, 모니터 달린 로컬 데스크톱에서 실행 (record 터미널이 포커스된 상태로 페달 사용).

---

## 폴더 구조

```
Norimate/
├── README.md
├── scripts/
│   ├── env.sh            # 포트/카메라/데이터셋 설정 (여기만 고치면 됨)
│   ├── 1_find_ports.sh   # 시리얼 포트 & 카메라 탐색
│   ├── 2_calibrate.sh    # 팔 4개 캘리브레이션
│   ├── 3_teleoperate.sh  # 움직임/카메라 점검 (녹화 X)
│   └── 4_record.sh        # 데이터 수집 (RGB+Depth)
├── pedal/
│   ├── pedal_bridge.py   # evdev grab + 디바운스 + uinput 재전송
│   ├── pedal_config.yaml # 키 매핑 · 디바운스 값
│   ├── requirements.txt
│   └── udev/99-norimate-pedal.rules
└── setup/
    └── install.sh        # 페달 브릿지 의존성 · 권한 세팅 (1회)
```

---

## 설치

### 1. LeRobot

공식 문서를 따라 설치한다: https://github.com/huggingface/lerobot
설치되면 `lerobot-record`, `lerobot-calibrate`, `lerobot-teleoperate`, `lerobot-find-port` 명령이 생긴다.

### 2. 페달 브릿지 (1회)

```bash
bash setup/install.sh
# 끝나면 로그아웃/재로그인 (input 그룹 반영)
```

이 스크립트가 하는 일: 파이썬 의존성 설치, `uinput` 커널 모듈 활성화,
udev 룰 설치(페달 + uinput 권한), 유저를 `input` 그룹에 추가.

---

## 사용 순서

먼저 `scripts/env.sh`를 열어 포트·카메라·데이터셋 값을 채운다.

### 1) 포트 & 카메라 확인

```bash
bash scripts/1_find_ports.sh
```

- 팔 4개의 `/dev/ttyACM*`를 찾아 `env.sh`의 `*_PORT`에 기입
- 손목 카메라는 재부팅해도 안 바뀌는 `/dev/v4l/by-id/...` 경로로 지정 (인덱스 번호 쓰지 말 것)
- RealSense는 시리얼 번호로 지정

### 2) 캘리브레이션 (팔 4개)

```bash
bash scripts/2_calibrate.sh
```

각 팔을 중립 자세로 두고 Enter → 전 관절을 가동 범위 끝까지 움직여 준다. 4개 모두 반복.
결과는 `~/.cache/huggingface/lerobot/calibration/...`에 팔별 JSON으로 저장된다.

> 캘리브레이션 id는 `<ID>_left` / `<ID>_right` 규칙을 따른다. 양팔 로봇이 이 접미사로 파일을 찾기 때문.

### 3) 텔레오퍼레이션 점검

```bash
bash scripts/3_teleoperate.sh
```

리더로 팔로워가 잘 따라오는지, **좌/우 카메라가 뒤바뀌지 않았는지**, 충돌 위험이 없는지 확인한다.
데이터는 저장되지 않는다.

### 4) 데이터 수집

터미널 2개를 쓴다.

**터미널 A — 페달 브릿지**
```bash
python3 pedal/pedal_bridge.py
```

**터미널 B — 녹화 (이 창을 포커스한 채로 페달 사용)**
```bash
bash scripts/4_record.sh
```

이제 발로 제어한다: 오른쪽=저장&다음, 왼쪽=재수집, 중앙(꾹)=종료.

---

## 페달 브릿지 상세

`pedal_bridge.py`는 물리 페달을 **독점(grab)** 해서 raw 입력이 터미널로 새는 걸 막고,
디바운스를 거친 뒤 **가상 키보드(uinput)** 로 `n`/`r`/`q`를 다시 쏜다. uinput은 커널 레벨이라
X11이든 Wayland든 포커스된 창(=녹화 터미널)에 그대로 전달된다.

### 페달 설정하기

```bash
# 1) 페달 장치 경로 찾기
python3 pedal/pedal_bridge.py --list

# 2) 각 페달이 보내는 코드 확인 (페달 하나씩 밟아보며 code= 값 기록)
python3 pedal/pedal_bridge.py --detect --device /dev/input/by-id/<너의-페달>
```

확인한 값으로 `pedal/pedal_config.yaml`의 `device`와 `bindings`의 `code`를 채운다.

### 오작동 방지 (디바운스)

- **key-down에서만** 반응. 누르고 있을 때 나오는 auto-repeat, 뗄 때 신호는 무시.
- **액션별 쿨다운**(기본 0.5s): 같은 페달을 실수로 연타해도 한 번만 먹는다.
- **전역 락아웃**(기본 0.15s): 발이 미끄러져 두 페달이 거의 동시에 밟혀도 하나만 처리.
- **중앙(종료)은 hold-to-confirm**: 최소 0.4초 이상 밟고 있어야 발동. 스치듯 밟았다고 세션이 끝나지 않는다.

값은 모두 `pedal_config.yaml`에서 조정 가능하다.

---

## Depth 관련 메모

상단 RealSense는 **RGB + Depth**로 기록한다 (`use_depth: true`). record 스크립트에서
depth 인코딩 범위를 미터 단위로 지정한다:

```
--dataset.depth_encoder.depth_min=0.05
--dataset.depth_encoder.depth_max=2.0
--dataset.depth_encoder.use_log=true
```

- `depth_max`를 작업 공간 살짝 바깥(테이블탑이면 1.5~2.0m)까지로 좁히면 depth 해상도가 좋아진다.
- Depth는 저장 용량과 학습 시간을 늘린다(표준 ACT 기준 대략 2배). 그래도 정밀한 3D 작업엔 도움이 된다.
- **주의:** depth는 소급 적용이 안 된다. 이미 찍은 에피소드에 나중에 붙일 수 없으니 처음부터 켜서 수집.

---

## 트러블슈팅

- **`bi_so_follower` 타입 에러** → 버전마다 문자열이 다를 수 있다. `lerobot-record --help`로 사용 가능한
  `robot.type` 목록 확인. 버전에 따라 `bi_so100_follower` / `bi_so100_leader`일 수 있다.
- **캘리브레이션을 못 찾는다** → `env.sh`의 `FOLLOWER_ID`/`LEADER_ID`와 `2_calibrate.sh`가 만든
  `<ID>_left` / `<ID>_right` 파일명이 맞는지 확인.
- **좌/우 카메라가 바뀜** → `/dev/videoN` 대신 `/dev/v4l/by-id/...` 고정 경로 사용.
- **페달을 밟아도 반응 없음** → 녹화 터미널이 포커스돼 있는지, `input` 그룹 반영을 위해 재로그인했는지 확인.
  `pedal_bridge.py --detect`로 페달이 코드를 보내는지부터 점검.
- **플래그가 거부됨** → LeRobot 버전에 따라 플래그명이 바뀐다. 해당 명령에 `--help`.

---

## 참고

- LeRobot 실사용 문서: https://huggingface.co/docs/lerobot/il_robots
- 양팔 SO-ARM 가이드(Seeed): https://wiki.seeedstudio.com/lerobot_double_arm_so_arm_training/
- PCsensor 페달 리눅스 프로그래밍 툴: https://github.com/rgerganov/footswitch
