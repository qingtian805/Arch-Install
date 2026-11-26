#!/bin/bash

max_startups=5
netblock="32:64"
penalties="invaliduser: 10s"
root="forced-commands-only"
target="/etc/ssh/sshd_config.d/99-security-policies.conf"

echo "This script sets security options for sshd, \
	reducing DDoS influence and limits root access."
echo "Current Setting:"
echo "PerSourceMaxStartups: ${max_startups}"
echo "PreSourceNetBlockSize: ${netblock}"
echo "PerSourcePenalties: ${penalties}"
echo "PermitRootLogin: ${root}"
echo ""
echo "Press enter to continue"
read

config=$(cat << EOF
# DDoS protecttion
PerSourceMaxStartups ${max_startups}
PerSourceNetBlockSize ${netblock}
PerSourcePenalties ${penalties}
# Disable root
PermitRootLogin ${root}
EOF
)

echo "Writing configuration to ${target}"
sudo tee ${target} <<< ${config} > /dev/null
