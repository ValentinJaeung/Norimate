#!/usr/bin/env bash
# One-time setup for the Norimate pedal bridge on Ubuntu.
# (Assumes LeRobot itself is already installed — see README.)
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo ">>> Installing pedal bridge Python deps"
pip install -r "$REPO_DIR/pedal/requirements.txt"

echo ">>> Enabling uinput kernel module (virtual keyboard)"
sudo modprobe uinput
echo uinput | sudo tee /etc/modules-load.d/uinput.conf >/dev/null

echo ">>> Installing udev rules (pedal + uinput permissions)"
sudo cp "$REPO_DIR/pedal/udev/99-norimate-pedal.rules" /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

echo ">>> Adding $USER to the 'input' group"
sudo usermod -aG input "$USER"

echo
echo "Setup complete."
echo "IMPORTANT: log out and back in (or reboot) for the 'input' group to take effect."
echo "Then: python3 pedal/pedal_bridge.py --list   to find your pedal."
