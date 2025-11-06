#!/usr/bin/bash

config=\
'# set BFQ as default scheduler for HDD(scsi) and slow SSD(emmc)\n
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"\n
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"\n
'

echo -e "$config" | sudo tee -a /etc/udev/rules.d/60-schedulers.rules
