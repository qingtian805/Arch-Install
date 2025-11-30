#!/usr/bin/bash

udev=$(cat << 'EOF'
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
options nvidia "NVreg_DynamicPowerManagement=0x02"
EOF
)

read -p "Is your GPU Amphere(30xx and above)? [Y/n]" amphere
# modeprobed
# amphere need to set 0x03, while pre-amphere need to set 0x02
if [ "$amphere" != "n" -a "$amphere" != "N" ]; then
    modprobe_opt=`echo "$modprobe_opt" | sed 's/0x02/0x03/'`
fi

echo "$modprobe_opt" | sudo tee /etc/modprobe.d/nvidia-prime.conf

# udev
# pre-amphere need to set this
if [ "$amphere" = "n" -o "$amphere" = "N" ]; then
    echo "$udev" | sudo tee /etc/udev/rules.d/nvidia-prime.rules
fi

# Enable graphic memory persistence
sudo systemctl enable nvidia-persistenced

echo "Configure finished"
echo ""
echo "Reboot the system and run:"
echo ""
echo "cat /proc/driver/nvidia/gpus/0000:01:00.0/power"
echo ""
echo "to check whether it takes effect."
echo "If it doesn't, you may need to switch to "
echo "please refer to https://wiki.archlinux.org/title/PRIME#NVIDIA for help."
