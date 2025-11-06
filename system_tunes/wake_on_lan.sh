#!/usr/bin/bash

wol=\
'# This file defines the Wake-on-LAN (WOL) settings for all network interfaces.\n
# Definations:\n
# p   Wake on PHY activity\n
# u   Wake on unicast messages\n
# m   Wake on multicast messages\n
# b   Wake on broadcast messages\n
# a   Wake on ARP\n
# g   Wake on MagicPacket™\n
# s   Enable SecureOn™ password for MagicPacket™\n
# f   Wake on filter(s)\n
# d   Disable (wake on nothing). This option clears all previous options.\n
\n
ACTION=="add", SUBSYSTEM=="net", NAME=="en*", RUN+="/usr/bin/ethtool -s $name wol d"\n
'

echo "$wol" | sudo tee /etc/udev/rules.d/81-wol.rules
