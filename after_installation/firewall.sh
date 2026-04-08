#!/bin/bash

if pacman -Qi iptables-legacy > /dev/null; then
    echo "legacy iptables detected, not performing installation"
    exit 1
fi

if ! pacman -Qi firewalld > /dev/null; then
    echo "Installing firewalld..."
    sudo pacman -Syu firewalld
    sudo systemctl enable --now firewalld.service
fi

if [ -n "${XDG_SESSION_TYPE}" ]; then
    echo "DE detected, installing firewall-applet"
    sudo pacman -Syu firewall-applet
    echo "Relogin to see firewall-applet in system bus"
fi

echo "Firewalld installed successfully!"
echo "Applying rules..."

firewall-cmd --permanent --zone=trusted --change-interface=lo
firewall-cmd --reload
