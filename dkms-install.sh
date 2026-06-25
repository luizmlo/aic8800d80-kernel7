#!/bin/bash
# Install the AIC8800D80 driver via DKMS so it auto-rebuilds on kernel updates.
# DKMS only manages the kernel modules; firmware and the udev mode-switch rule
# are installed here as a one-time step.
set -e

NAME="aic8800d80"
VER="6.4.3.0"
SRC="/usr/src/${NAME}-${VER}"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root: sudo ./dkms-install.sh"
    exit 1
fi

if ! command -v dkms >/dev/null 2>&1; then
    echo "dkms is not installed. Install it first, e.g.:"
    echo "  sudo apt install dkms        # Debian/Ubuntu"
    echo "  sudo dnf install dkms        # Fedora"
    echo "  sudo pacman -S dkms          # Arch"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ">> Copying source to ${SRC}"
rm -rf "$SRC"
mkdir -p "$SRC"
cp -rf ./* "$SRC"/

echo ">> Installing firmware and udev mode-switch rule"
cp -rf ./fw/aic8800D80 /lib/firmware/
cp -f ./tools/aic.rules /etc/udev/rules.d/aic.rules
udevadm control --reload
udevadm trigger

echo ">> Registering and building with DKMS"
dkms remove "${NAME}/${VER}" --all 2>/dev/null || true
dkms add -m "$NAME" -v "$VER"
dkms build -m "$NAME" -v "$VER"
dkms install -m "$NAME" -v "$VER"

echo
echo ">> Done. dkms status:"
dkms status "$NAME"
echo
echo ">> Unplug and replug the adapter (or run: sudo modprobe aic8800_fdrv)."
