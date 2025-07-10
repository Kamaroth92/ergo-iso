#!/usr/bin/env bash

set -e -x

cp $FILES_DIR/netplan/configs/* /etc/netplan
chmod 600 /etc/netplan/*.yaml

# Register provisioner tasks
cp $FILES_DIR/netplan/provisioner/* $PROVISIONER_CONFIGS
