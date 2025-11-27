#!/usr/bin/env bash

if [[ -z "$VAR_name" ]]; then
	echo "Error: nodename not found for uuid $UUID"
	VAR_name=unknown-node
fi

echo "Using $VAR_name for hostname"
hostnamectl set-hostname "$VAR_name"
systemctl restart avahi-daemon
