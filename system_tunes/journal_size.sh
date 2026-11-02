#!/bin/bash

max_size=512M
max_time=2week

echo "本脚本设置 journalctl 的日志大小与保存时间"
echo "目前设置："
echo "日志大小：${max_size}"
echo "日志时长：${max_time}"

echo "如果要修改请参考https://man.archlinux.org/man/journald.conf.5"
echo "按 Enter 执行脚本 按 Ctrl+C 退出脚本"
read

if [ ! -d "/etc/systemd/journald.conf.d" ]; then
    sudo mkdir -p /etc/systemd/journald.conf.d
fi

content=$(cat << 'EOF'
[Journal]
SystemMaxUse=_MAX_SIZE_
MaxRetentionSec=_MAX_TIME_
EOF
)

content=$(sed "s/_MAX_SIZE_/${max_size}/g" <<< ${content})
content=$(sed "s/_MAX_TIME_/${max_time}/g" <<< ${content})

sudo tee /etc/systemd/journald.conf.d/99-size-limit.conf <<< ${content} > /dev/null
