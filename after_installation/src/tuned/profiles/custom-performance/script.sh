#!/bin/bash

start() {
    # Wifi powersave
    for interface in $(iw dev | grep Interface | awk '{print $2}'); do
        iw dev "$interface" set power_save off
    done
    
    # USB Auto Suspend
    for i in /sys/bus/usb/devices/*/power/control; do
        echo "on" > $i
    done

    # PCIe ASPM
    # Run sudo cat /sys/module/pcie_aspm/parameters/policy to see the avaliable policy
    echo performance > /sys/module/pcie_aspm/parameters/policy

    # Runtime PM
    # PCIe
    for i in /sys/bus/pci/devices/*/power/control; do
        echo "on" > $i
    done
    # Block device
    for i in /sys/block/*/device/power/control; do
        echo "on" > $i
    done
    # ATA
    for i in /sys/bus/pci/devices/*:17.*/ata*/power/control; do
        echo "on" > $i
    done

    return 0
}

stop() {
    return 0
}

$@
