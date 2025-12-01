#!/bin/bash

source ./utils.sh

shell="bash"

add_user() {
    user_name=$(input "Enter username")
    $CMD_BASE useradd -m $user_name -s `whereis $shell`

    echo "Set password for $user_name"
    $CMD_BASE passwd $user_name
    
    read -p "Should $user_name be in sudoers? [y/N]" sudo
    if [ "$sudo" = "y" -o "$sudo" = "Y" ]; then
        $CMD_BASE usermod -aG wheel $user_name
    fi
}

### Prepare disk
read -p "Need to partition the disk? [Y/n]" opt
if [ "$opt" != "n" -a "$opt" != "N" ]; then
    ./disk.sh
fi
./disk.sh

### Base system installation
echo "Installing base system..."
pacstrap -K /mnt base linux linux-firmware vim
# manual
pacstrap /mnt man-db man-pages texinfo

# zsh
read -p "Install zsh? [Y/n]" opt
if [ "$opt" != "n" -a "$opt" != "N" ]; then
    pacstrap /mnt zsh zsh-completions grml-zsh-config
    $CMD_BASE chsh -s `whereis zsh` root
    shell="zsh"
fi

### Base system configuration
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Clock
echo "Syncing clock..."
$CMD_BASE ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
$CMD_BASE hwclock --systohc

# Localization
echo "Configuring localization..."
$CMD_BASE echo "LANG=en_US.UTF-8" > /etc/locale.conf
$CMD_BASE sed -e "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
$CMD_BASE sed -e "s/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g" /etc/locale.gen

# Network: NetworkManager with systemd-resolved
host_name=$(input "Enter system hostname")
$CMD_BASE echo "$host_name" > /etc/hostname
pacstrap /mnt networkmanager
$CMD_BASE systemctl enable NetworkManager
$CMD_BASE systemctl enable systemd-resolved
$CMD_BASE ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Users
echo "Set password for root"
$CMD_BASE passwd

echo "Setting up sudo..."
pacstrap /mnt sudo
$CMD_BASE echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/50-allow-wheel

read -p "Create another user? [Y/n]" opt
if [ "$opt" != "n" -a "$opt" != "N" ]; then
    add_user()
done

# Drivers
echo "Installing CPU microcode..."
loop="y"
while [ "$loop" = "y" ]; do
    CPU=$(input "CPU manufacturer(Intel/AMD):")
    if [ "$CPU" = "Intel" ]; then
        pacstrap /mnt intel-ucode
        loop="n"
    elif [ "$CPU" = "AMD" ]; then
        pacstrap /mnt amd-ucode
        loop="n"
    else
        echo "Unknown CPU manufacturer."
    fi
done

echo "Installing graphic drivers..."
loop= "y"
while [ "$pass" != "n" -a "$pass" != "N" ]; do 
    ./graphic.sh
    read -p "Install another graphic driver? [Y/n]" loop
done

# Bootloader
./bootloader.sh
