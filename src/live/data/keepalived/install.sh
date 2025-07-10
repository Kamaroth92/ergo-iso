#!/usr/bin/env bash

set -e -x

apt-get install --yes keepalived
systemctl disable keepalived

cp $FILES_DIR/keepalived/keepalived.conf /etc/keepalived/keepalived.conf
cp $FILES_DIR/keepalived/check_rke2_health.sh /etc/keepalived/check_rke2_health.sh
chmod +x /etc/keepalived/check_rke2_health.sh

# Register provisioner tasks
cp $FILES_DIR/keepalived/provisioner/* $PROVISIONER_CONFIGS
