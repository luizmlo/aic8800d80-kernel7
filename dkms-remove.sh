#!/bin/bash
# Remove the AIC8800D80 DKMS module, firmware and udev rule.
set -e

NAME="aic8800d80"
VER="6.4.3.0"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root: sudo ./dkms-remove.sh"
    exit 1
fi

dkms remove "${NAME}/${VER}" --all 2>/dev/null || true
rm -rf "/usr/src/${NAME}-${VER}"
rm -f /etc/udev/rules.d/aic.rules
rm -rf /lib/firmware/aic8800D80
udevadm control --reload

echo "Removed ${NAME}/${VER} (modules, firmware, udev rule)."
