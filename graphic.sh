#!/bin/bash

source ./utils.sh

graphic_intel() {
    echo "Intel graphic driver selection"
    echo ""
    echo "Available options:"
    echo "default: Intel graphic driver for OpenGL, VA-API and Vulkan"
    echo "amber:   Intel graphic driver with amber(for gen7 and older)"
    echo "DDX:     Intel graphic driver with DDX driver(Not recommended)"
    echo "libva:   Intel VA-API with libva(gen8 and older)"
    echo ""
    echo "You can select multiple options by separating them with space(eg. amber DDX)"
    echo ""

    selection=$(input "Your selection [amber/DDX]:")

    drivers="mesa vulkan-intel intel-media-driver"

    if [[ "$selection" =~ "DDX" ]]; then
        drivers+=" xf86-video-intel"
    fi
    if [[ "$selection" =~ "amber" ]]; then
        drivers=`echo "$drivers"| sed "s/mesa/mesa-amber/g"`
    fi
    if [[ "$selection" =~ "libva" ]]; then
        drivers=`echo "$drivers"| sed "s/intel-media-driver/libva-intel-driver/g"`
    fi

    pacstrap /mnt $drivers
}

graphic_nvidia() {
    echo "Nvidia graphic driver selection"
    echo ""
    echo "Available options:"
    echo "default:  Nvidia graphic driver(open source) for OpenGL and Vulkan"
    echo "          Supports Turing(16xx,20xx) and newer, have power saving issue with Turing"
    echo "dkms:     Install Nvidia graphic driver with DKMS"
    echo "nouveau:  nouveau driver with OpenGL and Vulkan"
    echo "DDX:      nouveau driver with DDX driver(Not recommended)"
    echo ""
    echo "If you are using graphic card before 16xx, you need to install nouveau driver first"
    echo "and install card specific driver from AUR manually after installation"
    echo ""

    selection=$(input "Nvidia graphic driver selection [dkms/nouveau/DDX]:")

    drivers="nvidia-open"

    if [[ "$selection" =~ "dkms" ]]; then
        drivers=`echo "$drivers"| sed "s/nvidia-open/nvidia-open-dkms/"`
    fi
    if [[ "$selection" =~ "nouveau" ]]; then
        drivers="mesa vulkan-nouveau"
        if [[ "$selection" =~ "DDX" ]]; then
            drivers+=" xf86-video-nouveau"
        fi
    fi
    
    pacstrap /mnt $drivers
}

graphic_AMD() {
    echo "AMD graphic driver selection"
    echo ""
    echo "Available options:"
    echo "default: AMD graphic driver for OpenGL, VA-API and Vulkan"
    echo "DDX:     AMD graphic driver with DDX driver"
    echo ""

    selection=$(input "Your selection [DDX]:")

    drivers="mesa vulkan-radeon"

    if [[ "$selection" =~ "DDX" ]]; then
        drivers+=" xf86-video-amdgpu"
    fi

    pacstrap /mnt $drivers
}

graphic_ATI() {
    echo "AMD graphic driver selection"
    echo ""
    echo "Available options:"
    echo "default: ATI graphic driver for OpenGL"
    echo "amber:   ATI graphic driver with amber(R200 and prior)"
    echo "DDX:     ATI graphic driver with DDX driver(not recommended)"
    echo ""
    echo "You can select multiple options by separating them with space(eg. amber DDX)"
    echo ""

    selection=$(input "Your selection [amber/DDX]:")

    drivers="mesa"

    if [[ "$selection" =~ "DDX" ]]; then
        drivers+=" xf86-video-ati"
    fi
    if [[ "$selection" =~ "amber" ]]; then
        drivers=`echo "$drivers"| sed "s/mesa/mesa-amber/g"`
    fi

    #pacstrap /mnt $drivers
    echo "$drivers"
}

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