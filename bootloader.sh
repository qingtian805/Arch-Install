#!/bin/bash

# Check UEFI
if [ ! -e /sys/firmware/efi/fw_platform_size ]; then
    echo "You seems using BIOS. However, this script is designed for UEFI."
    exit
fi

source ./utils.sh

# Flags
ldr_mpoint=""
efi_mpoint="/mnt/boot"
removable="N"

detect_partition() {
    local efi_list=$(lsblk -o PARTTYPE,MOUNTPOINT | grep -i c12a7328-f81f-11d2-ba4b-00a0c93ec93b)
    local ldr_list=$(lsblk -o PARTTYPE,MOUNTPOINT | grep -i bc13c2ff-59e6-4262-a352-b275fd6f7172)

    # Check the mount point within /mnt
    efi_mpoint=$(grep "/mnt/" <<< "${efi_list}" | awk '{print $2}' | sed 's/\/mnt//g')
    ldr_mpoint=$(grep "/mnt/" <<< "${ldr_list}" | awk '{print $2}' | sed 's/\/mnt//g')

    if [ -z "${efi_mpoint}" ]; then
        echo "[BOOTLOADER] ERROR: EFI partition not detected"
        exit
    fi
}

systemd_entry=$(cat << 'EOF'
title   Arch Linux (linux)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=__ROOT_UUID__ zswap.enabled=0 rw rootfstype=ext4
EOF
)

systemd_boot() {
    local options=""

    # Process flags
    if [ "${removable}" == "Y" ]; then
        options+="--variables=no "
    fi
    if [ "${ldr_mpoint}" != "" ]; then
        options+="--boot-path=${ldr_mpoint} --esp-path=${efi_mpoint} "
    fi

    echo "Installing systemd-boot..."
    $CMD_BASE bootctl install $options

    echo "Configuring systemd-boot..."
    $CMD_BASE sed "s/#timeout 3/timeout 5/g" /boot/loader/loader.conf

    echo "Setting up entry..."
    # Get root partition UUID
    root_uuid=`lsblk -o NAME,MOUNTPOINT,UUID | grep "/mnt " | awk '{print $3}'`
    # Generate entries
    conf=$(echo "${systemd_entry}" | sed "s/__ROOT_UUID__/${root_uuid}/g")
    conf_fallback=$(sed "s/initramfs-linux/initramfs-linux-fallback/g" <<< "${conf}")

    $CMD_BASE echo "${conf}"          > /boot/loader/entries/linux.conf
    $CMD_BASE echo "${conf_fallback}" > /boot/loader/entries/linux-fallback.conf
}

grub() {
    local options="--target=x86_64-efi --bootloader-id=GRUB "

    # Process flags
    if [ $removable = "Y" ]; then
        options=$(echo "${options}" | sed "s/--bootloader-id=GRUB/--removable/g")
    fi
    # Grub need not change using xbootldr
    options+= "--efi-directory=${efi_mpoint} "

    echo "Installing grub..."
    pacstrap /mnt grub
    $CMD_BASE pacman -S --asdeps efibootmgr

    $CMD_BASE grub-install ${options}
    $CMD_BASE grub-mkconfig -o /boot/grub/grub.cfg
}

detect_partition

read -p "Is the device removable from system? [y/N]" opt
if [ "$opt" != "y" -a "$opt" = "Y" ]; then
    removable="N"
else
    removable="Y"
fi

bootloader=$(input "Bootloader you want to use [systemd-boot/grub]:")
if   [ "$bootloader" = "systemd-boot" ]; then
    systemd_boot
elif [ "$bootloader" = "grub" ]; then
    grub
fi
