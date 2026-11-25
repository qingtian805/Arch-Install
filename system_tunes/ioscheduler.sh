#!/bin/bash

sched_slow="bfq"
sched_fast="none"
target_file="/etc/udev/rules.d/60-ioschedulers.rules"

echo "This script will set i/o scheduler for storage device to improve performance"
echo "Current setting:"
echo "${sched_slow} for HDD and emmc"
echo "${sched_fast} for nvme-ssd"
echo ""
echo "Press Enter to continue..."
read

config=$(cat << EOF
# set BFQ as default scheduler for HDD(scsi) and slow SSD(emmc)
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="${sched_slow}"
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${sched_slow}"
# set None as default scheduler for NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="${sched_fast}"
EOF
)

cat <<< ${config}

echo "Writing config to ${target_file}"
echo "$config" | sudo tee ${target_file} > /dev/null
