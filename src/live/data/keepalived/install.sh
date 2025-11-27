#!/usr/bin/env bash

set -e -x

apt-get install --yes keepalived
systemctl disable keepalived

cp $FILES_DIR/keepalived/keepalived.conf /etc/keepalived/keepalived.conf
chmod 644 /etc/keepalived/keepalived.conf

mkdir -p /etc/keepalived/scripts
cp $FILES_DIR/keepalived/scripts/*.sh /etc/keepalived/scripts
chmod +x /etc/keepalived/scripts/*.sh

# Register provisioner tasks
cp $FILES_DIR/keepalived/provisioner/* $PROVISIONER_CONFIGS
