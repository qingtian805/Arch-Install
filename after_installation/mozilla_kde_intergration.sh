#!/bin/bash

# This script will setup Mozilla applications to work with KDE Plasma
# 
# How it works: 
# Using enterprise policy file in /etc/{firefox,thunderbird}/policies/policies.json

profile=$(cat << 'EOF'
{
    "policies": {
        "Preferences": {
            "widget.use-xdg-desktop-portal.file-picker": {
                "Value": 1,
                "Status": "default"
            },
            "widget.gtk.global-menu.enabled": {
                "Value": true,
                "Status": "default"
            },
            "widget.gtk.global-menu.wayland.enabled": {
                "Value": true,
                "Status": "default"
            }
        }
    }
}
EOF
)

mozilla_kde_intergration() {
    pacman -Qi ${1} > /dev/null
    if [ $? -eq 1 ]; then
        echo "${1} not detected"
        exit 1
    fi
    pacman -Qi xdg-desktop-portal-kde > /dev/null
    if [ $? -eq 1 ]; then
        echo "xdg-desktop-portal-kde not detected"
        exit 1
    fi

    # Edit profile
    if [ "${1}" = "thunderbird" ]; then
        profile=$(echo "$profile" | sed '4,7d')
    fi

    sudo mkdir -p /etc/${1}/policies
    sudo tee /etc/${1}/policies/policies.json <<< "$profile" > /dev/null
}

mozilla_kde_intergration firefox
mozilla_kde_intergration thunderbird
