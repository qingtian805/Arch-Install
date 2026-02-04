#!/bin/bash

# From Arch Wiki:
# If you are using Amper(30xx) and above, you DO NOT really need to do anything.

if [ ! -d /proc/driver/nvidia ]; then
    echo "Please check whether you have installed Nvidia driver correctly."
    exit
fi

if [ `grep "Runtime D3" /proc/driver/nvidia/gpus/0000:01:00.0/power | awk '{print $4}'` = "Enabled" ]; then
    echo "Your GPU is already enabled runtime PM."
    exit
fi

udev=$(cat << 'EOF'
# Remove NVIDIA USB xHCI Host Controller devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

# Remove NVIDIA USB Type-C UCSI devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

# Remove NVIDIA Audio devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
EOF
)

modprobe_opt=$(cat << 'EOF'
# Enable Nvidia PRIME
options nvidia "NVreg_DynamicPowerManagement=0x03"
EOF
)

modprobe_disable_gsp=$(cat << 'EOF'
options nvidia "NVreg_EnableGpuFirmware=0"
EOF
)

prime_tu_xxx() {
    modprobe_opt=`echo "${modprobe_opt}" | sed 's/0x03/0x02/'`

    echo "Writing config files"
    echo "Enabling RTD3"
    sudo tee /etc/modprobe.d/nvidia-pm.conf <<< "${modprobe_opt}" > /dev/null
    echo "Disabling GSP firmware..."
    sudo tee -a /etc/modprobe.d/nvidia-pm.conf <<< "${modprobe_disable_gsp}" > /dev/null
    echo "Udev rules..."
    sudo tee /etc/udev/rules.d/80-nvidia-pm.rules <<< "${udev}" > /dev/null
}

prime_amp_above() {
    echo "Writing config files"
    echo "Enabling RTD3"
    sudo tee /etc/modprobe.d/nvidia-pm.conf <<< "${modprobe_opt}" > /dev/null
    echo "Udev rules..."
    sudo tee /etc/udev/rules.d/80-nvidia-pm.rules <<< "${udev}" > /dev/null
}

### Main

# RTD3
if lspci -d ::03xx | grep NVIDIA | grep 'TU1[0,1][2,4,6,7]'; then
    echo "Turing detected, using turing profile"
    prime_tu_xxx
else
    prime_amp_above
fi

echo "Enabling graphic memory persistence..."
sudo systemctl enable nvidia-persistenced > /dev/null

echo ""
echo "Configure finished"
echo ""
echo "Reboot the system and run:"
echo ""
echo "cat /proc/driver/nvidia/gpus/0000:01:00.0/power"
echo ""
echo "to check whether it takes effect."
echo "If it doesn't, you may need to switch to "
echo "please refer to https://wiki.archlinux.org/title/PRIME#NVIDIA for help."
