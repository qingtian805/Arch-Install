#!/bin/bash

config=$(cat << 'EOF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell
[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1
EOF
)

echo "$config" | sudo tee /etc/sddm.conf.d/10-wayland.conf