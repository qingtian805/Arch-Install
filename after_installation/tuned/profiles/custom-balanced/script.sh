#!/bin/bash

start() {
    # Wifi powersave
    for interface in $(iw dev | grep Interface | awk '{print $2}'); do
        iw dev "$interface" set power_save on
    done

    # USB Auto Suspend
    find /sys/bus/usb/devices -not -name "*:*" -not -wholename "/sys/bus/usb/devices" | while read -r usb_dev; do
        mark="auto"
        # Disable on mouse and keyboard
        for i in ${usb_dev}/*:*; do
            if [ `cat "${i}/bInterfaceClass"` != "03" ]; then
                continue
            fi
            if [ `cat "${i}/bInterfaceSubClass"` != "01" ]; then
                continue
            fi
            if [ `cat "${i}/bInterfaceProtocol"` = "01" -o `cat "${i}/bInterfaceProtocol"` = "02" ]; then
                mark="on"
                break
            fi
        done

        if [ -e "${usb_dev}/power/control" ]; then
            echo "${mark}" > ${usb_dev}/power/control
        fi
    done

    # PCIe ASPM
    # Run sudo cat /sys/module/pcie_aspm/parameters/policy to see the avaliable policy
    echo default > /sys/module/pcie_aspm/parameters/policy

    # Runtime PM
    # PCIe
    for i in /sys/bus/pci/devices/*/power/control; do
        echo "auto" > $i
    done
    # Block device
    for i in /sys/block/*/device/power/control; do
        echo "auto" > $i
    done
    # ATA
    for i in /sys/bus/pci/devices/*:17.*/ata*/power/control; do
        echo "auto" > $i
    done

    return 0
}

stop() {
    return 0
}

$@
