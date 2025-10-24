#!/usr/bin/bash

# This program designed for archiso ONLY
source ./base.sh

connect_to_wifi() {
    local wlan
    # Get the wireless interface
    iwctl device list

    wlan=$(input "Enter the NAME of your wireless interface: ")

    # Set power on
    for i in 1 2 3; do
        
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

partition_disk() {
    local disk
    echo "Listing Disks..."
    ls /dev/ | grep -Ew "(sd[a-z]|nvme[0-9]+n[0-9]+)"
    
    disk=$(input "Enter the disk you want to partition: ")
    echo "WARING: This will wipe all data on the disk!"
    read -p "Confirm? [y/N] " confirm
    if [ "$confirm" != "y" -a "$confirm" != "Y" ]; then
        echo "Aborted."
        exit
    fi

    parted --script /dev/$disk \
        mklabel gpt \
        mkpart ESP 1MiB 1025MiB \
        mkpart ROOT 1025MiB 100% \
        set 1 boot on
    
    part_prefix=""
    if [[ $disk =~ ^nvme ]]; then
        part_prefix="${disk}p"
    else
        part_prefix="${disk}"
    fi
    
    # 格式化分区
    mkfs.fat -F32 /dev/${part_prefix}1
    mkfs.ext4 /dev/${part_prefix}2S

    echo "Partitioning completed."
    parted /dev/${disk} print

    echo "Mounting partitions..."
    mount /dev/${disk}2 /mnt
    mount --mkdir /dev/${disk} /mnt/boot
}

if [ ! -e /sys/firmware/efi/fw_platform_size ]; then
    echo "You seems using BIOS, please refer Arch Wiki instead."
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
read -p "Need partitioning? [Y/n] " opt

if [ -z "$opt" -o "$opt" = "y" ]; then
    partition_disk
fi

echo "Installing base system..."
pacstrap -K /mnt base linux linux-firmware vim

echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
