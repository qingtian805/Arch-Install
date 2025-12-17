#!/bin/bash

# This script will setup Firefox to work with KDE Plasma
# 
# How it works: 
# Using firefox enterprise policy file in /etc/firefox/policies/policies.json

pacman -Qi firefox > /dev/null
if [ $? -eq 1 ]; then
    echo "Firefox not detected"
    exit 1
fi
pacman -Qi xdg-desktop-portal-kde > /dev/null
if [ $? -eq 1 ]; then
    echo "xdg-desktop-portal-kde not detected"
    exit 1
fi

profile=$(cat << 'EOF'
{
   "policies": {
        "Preferences": {
            "widget.gtk.global-menu.enabled": {
                "Value": true,
                "Status": "default"
            },
            "widget.gtk.global-menu.wayland.enabled": {
                "Value": true,
                "Status": "default"
            },
            "widget.use-xdg-desktop-portal.file-picker": {
                "Value": 1,
                "Status": "default"
            },
        }
    }
}
EOF
)

sudo mkdir -p /etc/firefox/policies
sudo tee /etc/firefox/policies/policies.json <<< "$profile"
