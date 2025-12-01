#!/bin/bash

wol=$(cat << 'EOF'
# This file defines the Wake-on-LAN (WOL) settings for all network interfaces.
# Definations:
# p   Wake on PHY activity
# u   Wake on unicast messages
# m   Wake on multicast messages
# b   Wake on broadcast messages
# a   Wake on ARP
# g   Wake on MagicPacket™
# s   Enable SecureOn™ password for MagicPacket™
# f   Wake on filter(s)
# d   Disable (wake on nothing). This option clears all previous options.

ACTION=="add", SUBSYSTEM=="net", NAME=="en*", RUN+="/usr/bin/ethtool -s $name wol d"
EOF
)

echo "$wol" | sudo tee /etc/udev/rules.d/81-wol.rules
