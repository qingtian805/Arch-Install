#!/bin/bash

if [ ! -d "/etc/sddm.conf.d" ]; then
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

echo "$config" | sudo tee /etc/sddm.conf.d/10-wayland.conf