#!/bin/bash

echo "本脚本用于设置 rclone 在开机时自动从远端拉取文件"
echo ""
echo "将设置 rclone 并安装一个用户 systemd 服务，自动在联网后进行同步"
echo "按 Enter 执行脚本 按 Ctrl+C 退出脚本"
read

if ! pacman -Qi rclone > /dev/null; then
    echo "rclone 未安装，安装 rclone..."
    sudo pacman -Syu rclone
fi

echo "正在配置 rclone, 请根据程序提示操作添加新远程"
rclone config

read -p "您配置的远程名称为：" remote
echo "正在安装 systemd 用户单元..."
cp src/rclone-sync@.service "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
systemctl --user daemon-reload
systemctl --user enable rclone-sync@${remote}.service

echo "完成配置，将在下次计算机重启时同步 ${remote}"
