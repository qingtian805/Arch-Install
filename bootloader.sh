#!/usr/bin/bash

source ./utils.sh

removable="0"

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
    part_UUID=`lsblk -o NAME,MOUNTPOINT,UUID | grep /mnt | awk '{print $3}'`
    conf="title   Arch Linux (linux)\nlinux   /vmlinuz-linux\ninitrd  /initramfs-linux.img\noptions root=PARTUUID=${part_UUID} zswap.enabled=0 rw rootfstype=ext4"
    conf_fallback="title   Arch Linux (fallback)\nlinux   /vmlinuz-linux\ninitrd  /initramfs-linux-fallback.img\noptions root=PARTUUID=${part_UUID} zswap.enabled=0 rw rootfstype=ext4"
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

pass= "n"
bootloader=$(input "Bootloader you want to use [systemd-boot/grub]:")
if   [ "$bootloader" = "systemd-boot" ]; then
    systemd_boot
    pass="y"
elif [ "$bootloader" = "grub" ]; then
    grub
    pass="y"
