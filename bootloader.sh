#!/usr/bin/bash

source ./utils.sh

removable="0"

systemd_entry=$(cat << EOF
title   Arch Linux (linux)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=__ROOT_UUID__ zswap.enabled=0 rw rootfstype=ext4
EOF
)

systemd_entry_fallback=$(cat << EOF
title   Arch Linux (fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options root=PARTUUID=__ROOT_UUID__ zswap.enabled=0 rw rootfstype=ext4
EOF
)

systemd_boot() {
    options=""

    if [ $removable = "1" ]; then
        options+="--variables=no"
    fi

    echo "Installing systemd-boot..."
    $CMD_BASE bootctl install $options

    echo "Configuring systemd-boot..."
    $CMD_BASE sed "s/#timeout 3/timeout 5/g" /boot/loader/loader.conf

    echo "Setting up entry..."
    # Get root partition UUID
    part_UUID=`lsblk -o NAME,MOUNTPOINT,UUID | grep "/mnt " | awk '{print $3}'`
    # Generate entries
    conf=$(echo "$systemd_entry" | sed "s/__ROOT_UUID__/${part_UUID}/g")
    conf_fallback=$(echo "$systemd_entry_fallback" | sed "s/__ROOT_UUID__/${part_UUID}/g")

    $CMD_BASE echo -e "$conf" > /boot/loader/entries/linux.conf
    $CMD_BASE echo -e "$conf_fallback" > /boot/loader/entries/linux-fallback.conf
}

grub() {
    options="--target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB"

    if [ $removable = "1" ]; then
        options=$(echo "$options" | sed "s/--bootloader-id=GRUB/--removable/g")
    fi

    echo "Installing grub..."
    pacstrap /mnt grub
    $CMD_BASE pacman -S --asdeps efibootmgr

    $CMD_BASE grub-install $options
    $CMD_BASE grub-mkconfig -o /boot/grub/grub.cfg
}

read -p "Is the device removable from system? [Y/n]" opt
if [ "$opt" = "y" -o "$opt" = "Y" ]; then
    removable="1"
fi

bootloader=$(input "Bootloader you want to use [systemd-boot/grub]:")
if   [ "$bootloader" = "systemd-boot" ]; then
    systemd_boot
    pass="y"
elif [ "$bootloader" = "grub" ]; then
    grub
    pass="y"
fi
