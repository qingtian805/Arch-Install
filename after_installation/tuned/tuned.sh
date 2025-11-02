#!/usr/bin/bash

# Install tuned and tuned-ppd
# sudo pacman -Syu tuned-ppd

# sudo systemctl enable tuned-ppd

# Install Profiles
sudo cp -r ./profiles/* /etc/tuned/profiles
sudo chmod +x /etc/tuned/profiles/*/script.sh

# configure tuned-ppd
sudo cp -f ./ppd.conf /etc/tuned/ppd.conf

