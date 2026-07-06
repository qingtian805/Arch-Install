#!/bin/bash

mem=`LANG=en_US free | grep Mem: | awk '{print $2}'`

if [ $mem -lt 2621440 ];then
    exit 0
fi

target_file="/etc/sysctl.d/99-dirty-ratio.conf"
echo "Writing config to ${target_file}"

# 32MB and 16MB
sudo tee ${target_file} > /dev/null << EOF
vm.dirty_bytes = 33554432
vm.dirty_background_bytes = 16777216
EOF

echo "If you want to enable configs, run 'sudo sysctl --system'"
