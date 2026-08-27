#!/usr/bin/env bash
# Identify the serial ports of the 4 arms and the cameras.
set -euo pipefail

echo "=== Serial ports ==="
echo "Run this once per arm. It asks you to unplug the arm, then tells you its port."
echo "Do it 4 times (follower L/R, leader L/R) and write the ports into scripts/env.sh."
echo
lerobot-find-port

echo
echo "=== UVC wrist cameras (use the stable by-id paths) ==="
ls -l /dev/v4l/by-id/ 2>/dev/null || echo "  (no /dev/v4l/by-id — is a UVC camera plugged in?)"
echo
echo "For a friendlier view:  v4l2-ctl --list-devices"

echo
echo "=== RealSense serial ==="
if command -v rs-enumerate-devices >/dev/null 2>&1; then
  rs-enumerate-devices -s
else
  echo "  rs-enumerate-devices not found. Install librealsense, or try: lerobot-find-cameras"
fi
