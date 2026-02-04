#!/bin/bash

if ! lsmod | grep "nvidia" > /dev/null; then
    echo "Please check wheather you have nvidia property driver installed correctly!"
    exit 1
fi

if [ `grep PreserveVideoMemoryAllocations /proc/driver/nvidia/params | awk '{print $2}'` = "1" ]; then
    echo "You already have Nvida Hibernate enabled!"
    exit 0
fi

echo "Configure nvidia driver..."
sudo tee /etc/modprobe.d/nvidia-hibernate.conf <<< "options nvidia NVreg_PreserveVideoMemoryAllocations=1" > /dev/null

echo "Enabling services..."
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-resume.service

echo "Finished!"
