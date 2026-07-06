#!/bin/bash

base_dir=`dirname "\`pwd\`/$0"`
profile_dir="${base_dir}/src/tuned/profiles"
ppdconf_dir="${base_dir}/src/tuned/ppd.conf"

if ! [ -e "${profile_dir}" ]; then
    echo "[ERROR] Missing profiles file, please check shell working directory."
    exit 1
fi
if ! [ -e "${ppdconf_dir}" ]; then
    echo "[ERROR] Missing pdd config file, please check shell working directory."
    exit 1
fi

# Install tuned and tuned-ppd
if ! pacman -Qi tuned-ppd > /dev/null 2>&1;then
    echo "Installing tuned and its dependency..."
    sudo pacman -Syu tuned-ppd
fi
if ! pacman -Qi x86_energy_perf_policy > /dev/null 2>&1; then
    sudo pacman -Syu --asdeps x86_energy_perf_policy
fi

echo "Enabling service..."
sudo systemctl enable tuned-ppd

# Install Profiles
echo "Installing tuned profiles..."
if ! [ -e "/etc/tuned/profiles" ]; then
    mkdir -p /etc/tuned/profiles
fi
sudo cp -r ${profile_dir}/* /etc/tuned/profiles
sudo chmod +x /etc/tuned/profiles/*/script.sh

# configure tuned-ppd
echo "Configure tuned-ppd..."
sudo cp -f ${ppdconf_dir} /etc/tuned/ppd.conf

