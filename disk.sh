#!/bin/bash

source ./utils.sh

boot_index="1"
efi_index=""
root_index="2"
disk=""
part_prefix=""

partition_disk() {
    parted --script /dev/${disk} \
        mklabel gpt \
        mkpart \"\" 1MiB 1025MiB \
        mkpart \"\" 1025MiB 100% \
        set 1 boot on

    echo "Partitioning completed."
    parted /dev/${disk} print
}

format_disk() {
    echo "Formatting disk..."
    # ROOT and BOOT
    mkfs.ext4 /dev/${part_prefix}${root_index}
    mkfs.fat -F 32 /dev/${part_prefix}${boot_index}

    # XBOOTLDR
    if [ -n "$efi_index" ]; then
        # Linux Extended Boot
        parted --script /dev/${disk} \
            type ${boot_index} bc13c2ff-59e6-4262-a352-b275fd6f7172
    fi
}

mount_disk() {
    part_prefix="$1"
    echo "Mounting disk..."
    mount /dev/${part_prefix}${root_index} /mnt
    mount --mkdir /dev/${part_prefix}${boot_index} /mnt/boot

    if [ -n "$efi_index" ]; then
        mount --mkdir /dev/${part_prefix}${efi_index} /mnt/efi
    fi
}

### Main
echo "Preparing disk for system installation"
echo ""
echo "WARNING: This script assume using swap file instead of swap partition."
echo ""
echo "Press Enter to list disks"
read
fdisk -l | more
echo ""

disk=$(input "Enter the disk you want to use(without /dev/ prefix): ")
part_prefix="$disk"
if [[ $disk =~ ^nvme ]]; then
    part_prefix="${disk}p"
fi

declare -i op=0

echo "Defult layout:"
echo "Mount point    Size       Partition"
echo "/boot          1GiB       /dev/${part_prefix}${boot_index}"
echo "/              rest       /dev/${part_prefix}${root_index}"
read -p "Use the default layout?(Use whole disk) [Y/n]" opt

if [ "$opt" = "n" -o "$opt" = "N" ]; then
    declare -i op=1
    echo "None default layout is not supported, will start fdisk for manual partitioning"
    read -p "Press Enter to start fdisk..."
    fdisk /dev/$disk
    
    parted /dev/$disk --script print
    boot_index=$(input "INDEX of partition to mount under /boot (eg. 1): ")
    root_index=$(input "INDEX of partition to mount under / (eg. 2): ")
    efi_index=$(input "INDEX of partition to mount under /efi (If not needed, leave empty): ")
fi

while [ $op -lt 3 ]; do
    op=`expr $op + 1`
    case $op in
    1)
        read -p "Start from partitioning? [Y/n] " opt
        ;;
    2)
        read -p "Start from formatting? [Y/n] " opt
        ;;
    esac
    if [ -z "$opt" -o "$opt" = "y" -o "$opt" = "Y" ]; then
        break
    fi
done

while [ $op -le 3 ]; do
    case $op in
    1)
        partition_disk $disk
        ;;
    2)
        format_disk $part_prefix
        ;;
    3)
        mount_disk $part_prefix
        ;;
    esac
    op=`expr $op + 1`
done

