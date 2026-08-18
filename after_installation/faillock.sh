#!/bin/bash

deny=5

echo "本脚本设置 faillock，faillock是 pam 用于处理认证失败情况的组件"
echo "目前设置："
echo "允许失败次数：${deny}"

echo "如果要修改请参考https://man.archlinux.org/man/faillock.conf.5"
echo "按 Enter 执行脚本 按 Ctrl+C 退出脚本"
read

echo "设置 deny=${deny}"
sudo sed -i "/deny =/c\\deny = ${deny}" /etc/security/faillock.conf

echo "设置管理员用户组"
sudo sed -i "/admin_group =/c\\admin_group = wheel"
