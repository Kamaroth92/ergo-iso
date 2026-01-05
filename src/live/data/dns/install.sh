#!/usr/bin/env bash

set -e -x

curl -sSL https://download.technitium.com/dns/install.sh | bash
cp $FILES_DIR/dns/scripts/dns-join-cluster.sh /ergo/bin/dns-join-cluster.sh
chmod +x /ergo/bin/dns-join-cluster.sh

cp $FILES_DIR/ergo-provisioner/dns-join-cluster.service /etc/systemd/system/
cp $FILES_DIR/ergo-provisioner/dns-join-cluster.timer /etc/systemd/system/
systemctl enable dns-join-cluster.timer

# Register provisioner tasks
cp $FILES_DIR/dns/provisioner/* $PROVISIONER_CONFIGS
