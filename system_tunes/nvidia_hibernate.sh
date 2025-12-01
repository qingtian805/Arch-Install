#!/bin/bash

echo "Warning: You DO NOT really need to run this script."
echo "Arch Linux has enabled this by default."
echo "Run following command to check it first:"
echo ""
echo "grep PreserveVideoMemoryAllocations /proc/driver/nvidia/params"
echo ""
echo "If it returns 1, means it is enabled, you SHOULD exit."
echo "Press Control+C to exit, or press Enter to continue."

read 

echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" | sudo tee /etc/modprobe.d/nvidia-hibernate.conf

sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-resume.service
