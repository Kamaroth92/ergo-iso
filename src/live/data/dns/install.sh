#!/usr/bin/env bash

set -e -x

primaryVIP=192.168.10.13
secondaryVIP=192.168.10.11

curl -sSL https://download.technitium.com/dns/install.sh | bash

# Register provisioner tasks
cp $FILES_DIR/dns/provisioner/* $PROVISIONER_CONFIGS
