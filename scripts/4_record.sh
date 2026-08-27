#!/usr/bin/env bash
# Record a bimanual dataset.
#
# Cameras:  left_wrist (UVC), right_wrist (UVC), top (RealSense RGB + DEPTH)
#
# Episode control while recording (drive these with the foot pedal — see pedal/):
#   RIGHT pedal  -> n / →   save current episode, go to next
#   LEFT  pedal  -> r / ←   discard current episode, re-record
#   CENTER pedal -> q / ESC  stop, encode videos, save dataset  (hold to confirm)
#
# Start the pedal bridge in a second terminal BEFORE recording:
#   python3 pedal/pedal_bridge.py
# and keep THIS terminal focused so the emitted keys land here.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

lerobot-record \
  --robot.type=bi_so_follower \
  --robot.id="${FOLLOWER_ID}" \
  --robot.left_arm_config.port="${FOLLOWER_LEFT_PORT}" \
  --robot.right_arm_config.port="${FOLLOWER_RIGHT_PORT}" \
  --robot.left_arm_config.cameras="${LEFT_CAMS}" \
  --robot.right_arm_config.cameras="${RIGHT_CAMS}" \
  --teleop.type=bi_so_leader \
  --teleop.id="${LEADER_ID}" \
  --teleop.left_arm_config.port="${LEADER_LEFT_PORT}" \
  --teleop.right_arm_config.port="${LEADER_RIGHT_PORT}" \
  --dataset.repo_id="${DATASET_REPO_ID}" \
  --dataset.single_task="${SINGLE_TASK}" \
  --dataset.num_episodes="${NUM_EPISODES}" \
  --dataset.episode_time_s="${EPISODE_TIME_S}" \
  --dataset.reset_time_s="${RESET_TIME_S}" \
  --dataset.push_to_hub=false \
  --dataset.streaming_encoding=true \
  --dataset.depth_encoder.depth_min=0.05 \
  --dataset.depth_encoder.depth_max=2.0 \
  --dataset.depth_encoder.use_log=true \
  --display_data=true

# depth_min / depth_max are in METERS and set the range that gets quantized.
# Tighten depth_max to just beyond your workspace (e.g. 1.5–2.0 m for a tabletop)
# for better depth resolution. Values outside the range are clipped.
#
# Flag names can drift between LeRobot versions. If something is rejected, check:
#   lerobot-record --help
