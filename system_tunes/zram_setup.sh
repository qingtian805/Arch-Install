#!/bin/bash

# 脚本用于配置 zram-generator.conf
# 使用 sudo 将配置写入 /etc/systemd/zram-generator.conf

if ! pacman -Qi zram-generator; then
    echo "zram-generator not installed, installing..."
    sudo pacman -Syu zram-generator
fi

echo "配置写入 /etc/systemd/zram-generator.conf"
sudo tee /etc/systemd/zram-generator.conf > /dev/null <<EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF

echo "写入内核 swap 参数优化 zram, /etc/sysctl.d/99-vm-zram-parameters.conf"
sudo tee /etc/sysctl.d/99-vm-zram-parameters.conf > /dev/null << EOF
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
EOF

echo "启用 zram-generator 服务"
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service

echo "zram 设置完成！"
zramctl
