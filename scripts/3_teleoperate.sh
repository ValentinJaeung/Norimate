#!/usr/bin/env bash
# Teleoperation sanity check — move the followers with the leaders and watch the
# camera feeds. No dataset is recorded here. Use this to confirm calibration,
# camera assignment (left/right not swapped), and that nothing collides.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

lerobot-teleoperate \
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
  --display_data=true

# NOTE on robot type strings:
# If "bi_so_follower"/"bi_so_leader" errors on your LeRobot version, list the
# available types with:  lerobot-teleoperate --help
# Depending on version they may be bi_so100_follower / bi_so100_leader.
