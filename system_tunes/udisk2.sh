#!/bin/bash

# Make udisk2 automount to /media as shared fs
echo "正在设置 UDISKS_FILESYSTEM_SHARED"
echo "    写入规则让 udisk 将文件系统自动挂载到 /media 目录下"
sudo tee /etc/udev/rules.d/99-udisks2.rules > /dev/null <<EOF
# UDISKS_FILESYSTEM_SHARED
# ==1: mount filesystem to a shared directory (/media/VolumeName)
# ==0: mount filesystem to a private directory (/run/media/$USER/VolumeName)
# See udisks(8)
ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"
EOF

echo "    设置 /media 目录为 tmpfs"
sudo tee /etc/tmpfiles.d/media.conf > /dev/null <<EOF
D /media 0755 root root 0 -
EOF
