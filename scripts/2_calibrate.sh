#!/usr/bin/env bash
# Calibrate all 4 arms individually.
# SO-ARM100 and SO-ARM101 share the same code, so we use the so101_* types.
# Each arm is calibrated with the id the bimanual robot will look for:
#   <FOLLOWER_ID>_left, <FOLLOWER_ID>_right, <LEADER_ID>_left, <LEADER_ID>_right
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

echo ">>> Calibrating FOLLOWER LEFT (${FOLLOWER_LEFT_PORT})"
lerobot-calibrate --robot.type=so101_follower --robot.port="${FOLLOWER_LEFT_PORT}"  --robot.id="${FOLLOWER_ID}_left"

echo ">>> Calibrating FOLLOWER RIGHT (${FOLLOWER_RIGHT_PORT})"
lerobot-calibrate --robot.type=so101_follower --robot.port="${FOLLOWER_RIGHT_PORT}" --robot.id="${FOLLOWER_ID}_right"

echo ">>> Calibrating LEADER LEFT (${LEADER_LEFT_PORT})"
lerobot-calibrate --teleop.type=so101_leader --teleop.port="${LEADER_LEFT_PORT}"  --teleop.id="${LEADER_ID}_left"

echo ">>> Calibrating LEADER RIGHT (${LEADER_RIGHT_PORT})"
lerobot-calibrate --teleop.type=so101_leader --teleop.port="${LEADER_RIGHT_PORT}" --teleop.id="${LEADER_ID}_right"

echo
echo "Done. Calibration files are under:"
echo "  ~/.cache/huggingface/lerobot/calibration/robots/so101_follower/${FOLLOWER_ID}_{left,right}.json"
echo "  ~/.cache/huggingface/lerobot/calibration/teleoperators/so101_leader/${LEADER_ID}_{left,right}.json"
