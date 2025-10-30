#!/usr/bin/bash

CMD_BASE="arch-chroot /mnt"

input() {
    local prompt="$1"
    local ok="n"
    local user_input
    
    while [ "$ok" = "n" -o "$ok" = "N" ]; do
        read -p "$prompt" user_input
        echo "Your input is: $user_input" >&2  # 输出到stderr
        echo "" >&2
        read -p "Continue? [Y/n]?" ok
    done

    echo "$user_input"
}
