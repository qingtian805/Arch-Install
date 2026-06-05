#!/bin/bash

echo "本脚本在系统层级设置用户 XDG Direcotries, 详情见 https://wiki.archlinux.org/title/XDG_Base_Directory"
echo "环境变量写入 /etc/profile.d/xdg-dir.sh"
read

if ![ -z "$XDG_CACHE_HOME" -a -z "$XDG_CONFIG_HOME" -a -z "$XDG_DATA_HOME" -a -z "$XDG_STATE_HOME" ]; then
    echo "检测到已经设置 (或部分设置) XDG Direcotry Spec, 退出..."
    exit 1
fi

echo "正在写入配置"
sudo tee /etc/profile.d/wayland.sh > /dev/null << EOF
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
EOF

echo "设置完成！"