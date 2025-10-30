#!/usr/bin/bash

# This program designed for archiso ONLY
source ./utils.sh

connect_to_wifi() {
    local wlan
    # Get the wireless interface
    iwctl device list
    echo ""

    wlan=$(input "Enter the NAME of your wireless interface: ")

    # Set power on
    for i in 1 2 3; do
        echo ""
        read -p "Is it powered on? [y/N] " powered
        if [ "$powered" = "y" -o "$powered" = "Y" ]; then
            break
        fi

        if [ $i -eq 1 ]; then
            echo "Try enabling wifi via iwctl..."
            iwctl device $wlan set-property Powered on
        elif [ $i -eq 2 ]; then
            echo "Try enabling wifi via rfkill..."
            rfkill list
            read -p "Enter the INDEX of your wifi device: " index
            rfkill unblock $index
            iwctl device $wlan set-property Powered on
        elif [ $i -eq 3 ]; then
            echo "Unkonwn situation, please refer archwiki for help."
            exit
        fi
        iwctl device list
    done
    # Set station on
    for i in 1 2; do
        echo ""
        read -p "Is it in STATION mode? [y/N] " mode
        if [ "$mode" = "y" ]; then
            break
        fi

        if [ $i -eq 1 ]; then
            echo "Try turning on station mode..."
            iwctl device $wlan set-property Mode station
        elif [ $i -eq 2 ]; then
            echo "Unkonwn situation, please refer archwiki for help."
            exit
        fi
        iwctl device list
    done
    
    # Scan wireless networks
    echo "Scanning for wireless networks..."
    iwctl station "$wlan" scan && iwctl station "$wlan" get-networks
    
    # Input network name
    ssid=$(input "Enter the network name (SSID) you want to connect to: ")
    
    if [ -z "$ssid" ]; then
        echo "No network selected."
        exit
    fi
    
    # 连接网络
    echo "Connecting to '$ssid'..."
    iwctl station "$wlan" connect "$ssid"
}

### Boot checking
if [ ! -e /sys/firmware/efi/fw_platform_size ]; then
    echo "You seems using BIOS. However, this script is designed for UEFI, please refer Arch Wiki instead."
    exit
fi

### ISO setup stage
read -p "Do you have a working internet connection? [y/N] " opt
if [ -z "$opt" -o "$opt" = "n" ]; then
    connect_to_wifi
fi

echo "Enabling time sync..."
timedatectl set-timezone Asia/Shanghai && timedatectl set-ntp true

echo "Finding a mirror in China..."
reflector -c China > /etc/pacman.d/mirrorlist

### New system stage
echo ""
echo "Stage Complete"
echo "We are going to configure a new system"
echo ""
echo "Press Enter to call basic_configuration.sh"
read

./configure_new_system.sh

return 0
