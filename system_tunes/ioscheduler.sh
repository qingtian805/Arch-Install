#!/bin/bash

config=$(cat << EOF
# set BFQ as default scheduler for HDD(scsi) and slow SSD(emmc)
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
# set None as default scheduler for NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="none"
EOF
)

target_file="/etc/udev/rules.d/60-ioschedulers.rules"

echo "Writing config to ${target_file}"
echo "$config" | sudo tee ${target_file} > /dev/null
