#!/bin/bash

unblock_wlan() {
    local filter="Wireless LAN"
    if [ -n "${1}" ]; then
        filter="${1}"
    fi

    local target=$(rfkill list | grep "${filter}" | awk '{print $1}' | sed 's/://g')

    for i in ${target}; do
        rfkill unblock $i
    done
}

# Get the wireless interface
iwctl device list
echo ""

wlan=$(input "Enter the NAME of your wireless interface: ")
adapter=$(iwctl device list | grep $wlan | awk '{print $5}')

# Enable adapter
echo "Disabling rfkill..."
unblock_wlan ${adapter}

echo "Powering on..."
iwctl device $wlan set-property Powered on

echo "Setting station mode..."
iwctl device $wlan set-property Mode station

echo ""
iwctl device list
echo ""
echo "Please check Powered(on) and Mode(station) properties."
read

# Scan wireless networks
echo "Scanning for wireless networks..."
iwctl station "$wlan" scan && iwctl station "$wlan" get-networks

# Input network name
ssid=$(input "Enter the network name (SSID) you want to connect to: ")

if [ -z "$ssid" ]; then
    echo "No network selected."
    exit
fi

# 连接网络
echo "Connecting to '$ssid'..."
iwctl station "$wlan" connect "$ssid"