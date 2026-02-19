#!/bin/bash

if ! [ -e "./profiles" ]; then
    echo "[ERROR] Missing profiles file, please check shell working directory."
    exit 1
fi
if ! [ -e "./pdd.conf" ]; then
    echo "[ERROR] Missing pdd config file, please check shell working directory."
    exit 1
fi

# Install tuned and tuned-ppd
echo "Installing tuned and its dependency..."
sudo pacman -Syu tuned-ppd
if ! pacman -Qi x86_energy_perf_policy 1> /dev/null 2> /dev/null; then 
    sudo pacman -Syu --asdeps x86_energy_perf_policy
fi

sudo systemctl enable tuned-ppd

# Install Profiles
echo "Installing tuned profiles..."
if ! [ -e "/etc/tuned/profiles" ]; then
    mkdir -p /etc/tuned/profiles
fi
sudo cp -r ./profiles/* /etc/tuned/profiles
sudo chmod +x /etc/tuned/profiles/*/script.sh

# configure tuned-ppd
echo "Configure tuned-ppd..."
sudo cp -f ./ppd.conf /etc/tuned/ppd.conf

