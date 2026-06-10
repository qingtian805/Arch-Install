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

echo "设置 SystemMaxUse=${max_size}"
sudo sed -i "/SystemMaxUse=/c\\SystemMaxUse=${max_size}" /etc/systemd/journald.conf
echo "设置 MaxRetentionSec=${max_time}"
sudo sed -i "/MaxRetentionSec=/c\\MaxRetentionSec=${max_time}" /etc/systemd/journald.conf
