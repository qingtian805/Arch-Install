#!/bin/bash

echo "本脚本用于设置各种 GUI 库使用 Wayland, 详情见 https://wiki.archlinux.org/title/Wayland#GUI_libraries"
echo "环境变量写入 /etc/profile.d/wayland.sh"

echo "正在设置 QT5"
if ! pacman -Qi qt5-wayland > /dev/null; then
    echo "检测到 qt5-wayland 未安装, 正在安装..."
    sudo pacman -Syu --asdeps qt5-wayland
fi

echo "正在设置 SDL2"
sudo tee -a /etc/profile.d/wayland.sh > /dev/null << EOF
# SDL2
SDL_VIDEODRIVER="wayland,x11"
EOF

echo "正在设置 EFL"
sudo tee -a /etc/profile.d/wayland.sh > /dev/null << EOF
# EFL
ELM_DISPLAY=wl
EOF

echo "设置完成, 现在除了 GLEW, JAVA 软件外, 应该均默认使用 Wayland, 但还有一些情况需要手动处理:"
echo ""
echo "1. 部分 Electron 需自行设置 --ozone-platform=wayland 等, 请参考 https://wiki.archlinux.org/title/Wayland#Electron"
echo "   以及 https://wiki.archlinux.org/title/Chromium#Native_Wayland_support"
echo "2. 一些不使用系统 QT 库的软件可能需要单独设置环境变量 QT_QPA_PLATFORM=\"wayland;xcb\""
