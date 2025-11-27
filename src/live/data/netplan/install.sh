#!/usr/bin/env bash

set -e -x

cp $FILES_DIR/netplan/configs/* /etc/netplan
chmod 600 /etc/netplan/*.yaml

# Configure the ethtool service to set ring parameters 
cp $FILES_DIR/netplan/ethtool-rings-enp1s0.service /etc/systemd/system/ethtool-rings-enp1s0.service
systemctl enable ethtool-rings-enp1s0.service

# Register provisioner tasks
cp $FILES_DIR/netplan/provisioner/* $PROVISIONER_CONFIGS
