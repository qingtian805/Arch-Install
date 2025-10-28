#!/usr/bin/bash

CMD_BASE="arch-chroot /mnt"

input() {
    local prompt="$1"
    local repeat="y"
    local user_input
    
    while [ "$repeat" = "y" -o "$repeat" = "Y" ]; do
        read -p "$prompt" user_input
        echo "Your input is: $user_input" >&2  # 输出到stderr
        read -p "Do you want to reinput? [y/N]?" repeat
    done

    echo "$user_input"
}
