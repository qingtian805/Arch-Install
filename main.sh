#!/bin/bash

# This program designed for archiso ONLY

### Boot checking
if [ ! -e /sys/firmware/efi/fw_platform_size ]; then
    echo "You seems using BIOS. However, this script is designed for UEFI."
    exit
fi

source ./utils.sh

### ISO setup stage
read -p "Need connect to Wifi? [Y/n] " opt
if [ "$opt" != "n" -a "$opt" != "N" ]; then
    ./connect_wifi.sh
fi

echo "Enabling time sync..."
timedatectl set-timezone Asia/Shanghai && timedatectl set-ntp true

echo "Finding a mirror in China..."
reflector -c China > /etc/pacman.d/mirrorlist


next_stage="./basic_system.sh"
### New system stage
echo ""
echo "Stage Complete"
echo "We are going to configure a new system"
echo ""
echo "Press Enter to call ${next_stage}..."
read

${next_stage}
