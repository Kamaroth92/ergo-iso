#!/usr/bin/env bash

set -e -x
shopt -s expand_aliases

export FILES_DIR=/work/data
export COMMON_DIR=/work/common
export VARS_DIR=/work/vars

mkdir -p /ergo
cp -r $VARS_DIR /ergo
source /work/build_vars.sh

apt-get update --yes
apt-get install --yes --no-install-recommends gnupg software-properties-common



source $FILES_DIR/packages/install.sh
# source $FILES_DIR/ufw/install.sh # Disabled because it's more hassle than it's worth
source $FILES_DIR/ergo-binaries/install.sh
source $FILES_DIR/ergo-provisioner/install.sh
source $FILES_DIR/os-installer/install.sh
source $FILES_DIR/motd/install.sh
source $FILES_DIR/user-administrator/install.sh
source $FILES_DIR/netplan/install.sh
source $FILES_DIR/sshd/install.sh
source $FILES_DIR/avahi-daemon/install.sh
source $FILES_DIR/set-multipath/install.sh
source $FILES_DIR/set-sysctl/install.sh
source $FILES_DIR/keepalived/install.sh
source $FILES_DIR/node-exporter/install.sh
source $FILES_DIR/rke2/install.sh
source $FILES_DIR/ansible/install.sh
source $FILES_DIR/intel-gpu-tools/install.sh
source $FILES_DIR/kexec/install.sh
# source $FILES_DIR/dns/install.sh
