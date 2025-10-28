#!/usr/bin/bash

source ./utils.sh

partition_disk() {
    disk="$1"

    parted --script $disk \
        mklabel gpt \
        mkpart ESP 1MiB 1025MiB \
        mkpart ROOT 1025MiB 100% \
        set 1 boot on
}

format_disk() {
    part_prefix="$1"

    mkfs.fat -F32 ${part_prefix}1
    mkfs.ext4 ${part_prefix}2
}

mount_disk() {
    part_prefix="$1"
    echo "Mounting disk..."
    mount ${part_prefix}2 /mnt
    mount --mkdir ${part_prefix}1 /mnt/boot
}

### Main
echo "Listing Disks..."
fdisk -l

disk=$(input "Enter the disk you want to use(without /dev/ prefix): ")
disk="/dev/${disk}"
part_prefix=""
if [[ $disk =~ ^nvme ]]; then
    part_prefix="${disk}p"
else
    part_prefix="${disk}"
fi

for i in 1 2 3; do
    case $i in
    1)
        read -p "Need partitioning? [Y/n] " opt
        ;;
    2)
        read -p "Need formatting? [Y/n] " opt
        ;;
    esac
    declare -i op=$i
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

echo "Partitioning completed."
parted ${disk} print
