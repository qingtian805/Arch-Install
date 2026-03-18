#!/bin/bash

if ! pacman -Qi pacman-contrib > /dev/null; then
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
Depends = pacman-contrib
Exec = /usr/bin/paccache -rk2
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
Depends = pacman-contrib
Exec = /usr/bin/paccache -ruk0
EOF

echo "配置完成，下次有软件包升级后会自动清理无用软件包"
