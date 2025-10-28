#!/usr/bin/bash

source ./utils.sh

graphic_intel() {
    echo "Intel graphic driver selection..."
    drivers="xf86-video-intel mesa vulkan-intel"

    if [ "$1" = "ark" ]; then
        drivers=`echo "$drivers"| sed "s/xf86-video-intel//g"`
    elif [ "$1" = "amber" ]; then
        drivers=`echo "$drivers"| sed "s/mesa/mesa-amber/g"`
    fi

    pacstrap /mnt $drivers
    
}

graphic_nvidia() {
    echo "Nvidia graphic driver selection..."
    drivers="nvidia nvidia-utils"

    if [ "$1" = "open" -a "$2" = "dkms" ] || [ "$1" = "dkms" -a "$2" = "open" ]; then
        drivers=`echo "$drivers"| sed "s/nvidia/nvidia-open-dkms/"`
    elif [ "$1" = "open" ]; then
        drivers=`echo "$drivers"| sed "s/nvidia/nvidia-open/"`
    elif [ "$1" = "dkms" ]; then
        drivers=`echo "$drivers"| sed "s/nvidia/nvidia-dkms/"`
    fi

    pacstrap /mnt $drivers
}

