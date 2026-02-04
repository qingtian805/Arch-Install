#!/bin/bash

if [ ${UID} -lt ]; then
    echo "Script must not run as root!"
    exit 1
fi

echo "Blocking fcitx autostart by xdg-autostart..."
if [ ! -e "~/.config/autostart" ]; then
    echo "xdg-autostart user config dir not exist, creating..."
    mkdir ~/.config/autostart
fi

echo "Hidden=true" > ~/.config/autostart/org.fcitx.Fcitx5.desktop

echo "Finished! Now you need to enable fcitx as Virtual Keybord in your desktop environment."
