#!/usr/bin/bash

config=$(cat << EOF
# set BFQ as default scheduler for HDD(scsi) and slow SSD(emmc)
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
EOF
)

echo "$config" | sudo tee -a /etc/udev/rules.d/60-schedulers.rules
