#!/usr/bin/bash

source ./utils.sh

partition_disk() {
    disk="$1"
    
    echo "WARING: This will wipe all data on the disk!"
    read -p "Confirm? [y/N] " confirm
    if [ "$confirm" != "y" -a "$confirm" != "Y" ]; then
        echo "Aborted."
        exit
    fi

    parted --script $disk \
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
    mkfs.fat -F32 ${part_prefix}1
    mkfs.ext4 ${part_prefix}2S

    echo "Partitioning completed."
    parted ${disk} print

    echo "Mounting partitions..."
    mount ${disk}2 /mnt
    mount --mkdir ${disk} /mnt/boot
}

add_user() {
    user_name=$(input "Enter username")
    $CMD_BASE useradd -m $user_name

    echo "Set password for $user_name"
    $CMD_BASE passwd $user_name
    
    read -p "Should $user_name be in sudoers? [y/N]" sudo
    if [ "$sudo" = "y" -o "$sudo" = "Y" ]; then
        $CMD_BASE usermod -aG wheel $user_name
    fi
}

systemd_boot() {
    echo "Installing systemd-boot..."
    $CMD_BASE bootctl install

    echo "Configuring systemd-boot..."
    $CMD_BASE sed "s/#timeout 3/timeout 5/g" /boot/loader/loader.conf

    echo "Setting up entry..."
    part_UUID=`lsblk -o NAME,MOUNTPOINT,UUID | grep /mnt | awk '{print $3}'`
    conf="title   Arch Linux (linux)\nlinux   /vmlinuz-linux\ninitrd  /initramfs-linux.img\noptions root=PARTUUID=${part_UUID} zswap.enabled=0 rw rootfstype=ext4"
    conf_fallback="title   Arch Linux (fallback)\nlinux   /vmlinuz-linux\ninitrd  /initramfs-linux-fallback.img\noptions root=PARTUUID=${part_UUID} zswap.enabled=0 rw rootfstype=ext4"
    $CMD_BASE echo -e "$conf" > /boot/loader/entries/linux.conf
    $CMD_BASE echo -e "$conf_fallback" > /boot/loader/entries/linux-fallback.conf
}

# Prepare disk
echo "Listing Disks..."
fdisk -l
    
disk=$(input "Enter the disk you want to use: ")

read -p "Need partitioning? [Y/n] " opt

if [ -z "$opt" -o "$opt" = "y" ]; then
    partition_disk $disk
fi

echo "Mounting disk..."
mount 

# Base system installation
echo "Installing base system..."
pacstrap -K /mnt base linux linux-firmware vim

# Base system configuration
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab


### Basic system configuration
# Clock
echo "Syncing clock..."
$CMD_BASE ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
$CMD_BASE hwclock --systohc

# Localization
echo "Configuring localization..."
$CMD_BASE echo "LANG=en_US.UTF-8" > /etc/locale.conf
$CMD_BASE sed -e "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
$CMD_BASE sed -e "s/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g" /etc/locale.gen

# Network
host_name=$(input "Enter system hostname")
$CMD_BASE echo "$host_name" > /etc/hostname

# Users
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
    CPU=$(input "CPU manufacturer:")
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

pass= "n"
while [ "$pass" != "y" ]; do 
    GPU=$(input "GPU manufacturer:")
    if [ "$GPU" = "NVIDIA" ]; then
        pacstrap /mnt nvidia nvidia-utils
    elif [ "$GPU" = "AMD" ]; then
        $CMD_BASE pacman -S xf86-video-amdgpu
        pass="y"
    else
        echo "Unknown GPU manufacturer."
    fi
done


# Bootloader
systemd_boot


