#!/bin/bash

if ! pacman -Qi pacman-contrib > /dev/null 2>&1; then
    echo "pacman-contrib not installed, installing..."
    sudo pacman -Syu pacman-contrib
fi

echo "配置写入 /etc/pacman.d/hooks/ccache-upgrade.hook"
sudo tee /etc/pacman.d/hooks/ccache-upgrade.hook > /dev/null <<EOF
[Trigger]
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Cleanning pacman cache(-rk2)...
When = PostTransaction
Depends = bash
Depends = pacman-contrib
Exec = /usr/bin/paccache -rk2 -c /var/cache/pacman/pkg/ -c /home/kevin/.cache/pikaur/pkg/
EOF

echo "配置写入 /etc/pacman.d/hooks/ccache-remove.hook"
sudo tee /etc/pacman.d/hooks/ccache-remove.hook > /dev/null <<EOF
[Trigger]
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleanning pacman cache(-ruk0)...
When = PostTransaction
Depends = bash
Depends = pacman-contrib
Exec = /usr/bin/paccache -ruk0 -c /var/cache/pacman/pkg/ -c /home/kevin/.cache/pikaur/pkg/
EOF

echo "配置写入 /etc/pacman.d/hooks/ccache-fail-dirs.hook"
sudo tee /etc/pacman.d/hooks/ccache-fail-dirs.hook > /dev/null <<EOF
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Cleanning download failure dirs...
When = PostTransaction
Depends = findutils
Exec = /usr/bin/find /var/cache/pacman/pkg -maxdepth 1 -mindepth 1 -type d -delete
EOF

echo "配置完成，下次有软件包升级后会自动清理无用软件包和下载失败目录"
