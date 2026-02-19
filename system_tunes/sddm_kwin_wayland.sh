#!/bin/bash

if ! pacman -Qi sddm 1> /dev/null 2> /dev/null; then
    echo "sddm is not installed!"
    exit 1
fi

if [ ! -d "/etc/sddm.conf.d" ]; then
    echo "SDDM config directory not exist, creating..."
    sudo mkdir /etc/sddm.conf.d
fi

config=$(cat << 'EOF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell
[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1
EOF
)

echo "Writing config file 10-wayland.conf"
echo "$config" | sudo tee /etc/sddm.conf.d/10-wayland.conf > /dev/null
echo "Finished! SDDM will use kwin as backend."
