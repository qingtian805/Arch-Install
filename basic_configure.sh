#!/usr/bin/bash

source ./utils.sh

add_user() {
    user_name=$(input "Enter username")
    $CMD_BASE useradd -m $user_name

    echo "Set password for $user_name"
    $CMD_BASE passwd $user_name
    
    read -p "Should $user_name be in sudoers? [y/N]" sudo
    if [ "$sudo" = "y" -o "$sudo" = "Y" ]; then
        $CMD_BASE usermod -aG wheel $user_name
    fi

    $CMD_BASE chsh -s /bin/zsh $user_name
}

### Prepare disk
./disk.sh

### Base system installation
echo "Installing base system..."
pacstrap -K /mnt base linux linux-firmware vim

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
echo "Installing zsh..."
pacstrap /mnt zsh zsh-completions grml-zsh-config
$CMD_BASE chsh -s /usr/bin/zsh root

echo "Set password for root"
$CMD_BASE passwd

echo "Setting up sudo..."
pacstrap /mnt sudo
$CMD_BASE echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/50-allow-wheel

read -p "Create another user? [y/N]" opt
if [ "$opt" = "y" -o "$opt" = "Y" ]; then
    add_user()
done

# Drivers
pass="n"
while [ "$pass" != "y" ]; do
    CPU=$(input "CPU manufacturer(Intel/AMD):")
    if [ "$CPU" = "Intel" ]; then
        pacstrap /mnt intel-ucode
        pass="y"
    elif [ "$CPU" = "AMD" ]; then
        pacstrap /mnt amd-ucode
        pass="y"
    else
        echo "Unknown CPU manufacturer."
    fi
done

source ./graphic.sh
pass= "n"
while [ "$pass" != "y" ]; do 
    GPU=$(input "GPU manufacturer(Intel/NVIDIA/AMD/ATI):")
    if   [ "$GPU" = "NVIDIA" ]; then
        graphic_nvidia
    elif [ "$GPU" = "Intel" ]; then
        graphic_intel
    elif [ "$GPU" = "AMD" ]; then
        graphic_AMD
    elif [ "$GPU" = "ATI" ]; then
        graphic_ATI
    else
        echo "Unknown GPU manufacturer."
    fi
    read -p "Select another graphic driver? [y/N]" pass
done


# Bootloader
source ./bootloader.sh
systemd_boot


