# Norimate — shared configuration.
# Edit the values below to match your machine, then all scripts pick them up.
# This file is meant to be sourced, not executed.

# ─── Serial ports (find with: scripts/1_find_ports.sh) ──────────────────────
export FOLLOWER_LEFT_PORT=/dev/ttyACM0
export FOLLOWER_RIGHT_PORT=/dev/ttyACM1
export LEADER_LEFT_PORT=/dev/ttyACM2
export LEADER_RIGHT_PORT=/dev/ttyACM3

# ─── Robot ids ──────────────────────────────────────────────────────────────
# The bimanual robot derives its two sub-arm ids by appending _left / _right.
# So calibration must be saved under "<ID>_left" and "<ID>_right" (script 2 does this).
export FOLLOWER_ID=norimate_follower
export LEADER_ID=norimate_leader

# ─── Cameras ────────────────────────────────────────────────────────────────
# Wrist cams: use STABLE by-id paths, not /dev/videoN (indices shuffle on reboot).
#   find with:  ls /dev/v4l/by-id/     or     v4l2-ctl --list-devices
# RealSense: identify by serial number.
#   find with:  rs-enumerate-devices -s     or     lerobot-find-cameras
export LEFT_WRIST_CAM=/dev/v4l/by-id/usb-CHANGE_ME_left-video-index0
export RIGHT_WRIST_CAM=/dev/v4l/by-id/usb-CHANGE_ME_right-video-index0
export TOP_REALSENSE_SERIAL=000000000000

# ─── Recording resolution / rate ────────────────────────────────────────────
export CAM_W=640
export CAM_H=480
export FPS=30

# ─── Dataset ────────────────────────────────────────────────────────────────
export HF_USER=ValentinJaeung
export DATASET_REPO_ID=${HF_USER}/norimate_bimanual
export SINGLE_TASK="describe the task here"
export NUM_EPISODES=50
# episode_time_s is only an upper bound — you normally end each episode early
# with the RIGHT pedal (next). reset_time_s is the pause between episodes.
export EPISODE_TIME_S=120
export RESET_TIME_S=20

# ─── Camera JSON blocks (built from the vars above) ─────────────────────────
# Top RealSense is attached to the LEFT arm config with depth ON.
export LEFT_CAMS="{ left_wrist: {type: opencv, index_or_path: ${LEFT_WRIST_CAM}, width: ${CAM_W}, height: ${CAM_H}, fps: ${FPS}}, top: {type: intelrealsense, serial_number_or_name: \"${TOP_REALSENSE_SERIAL}\", width: ${CAM_W}, height: ${CAM_H}, fps: ${FPS}, use_depth: true} }"
export RIGHT_CAMS="{ right_wrist: {type: opencv, index_or_path: ${RIGHT_WRIST_CAM}, width: ${CAM_W}, height: ${CAM_H}, fps: ${FPS}} }"
