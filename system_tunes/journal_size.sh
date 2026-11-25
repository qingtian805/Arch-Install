#!/bin/bash

max_size=512M
max_time=2week
target_file="/etc/systemd/journald.conf.d/99-size-limit.conf"

echo "This scripts configures how long and how many journals should be kept"
echo "Current Setting:"
echo "Size: ${max_size}"
echo "Time: ${max_time}"
echo ""
echo "Referance: https://man.archlinux.org/man/journald.conf.5"
echo "Press Enter to continue..."
read

if [ ! -d "/etc/systemd/journald.conf.d" ]; then
	sudo mkdir -p /etc/systemd/journald.conf.d
fi

content=$(cat << EOF
[Journal]
SystemMaxUse=${max_size}
MaxRetentionSec=${max_time}
EOF
)

sudo tee ${target_file} <<< ${content} > /dev/null
