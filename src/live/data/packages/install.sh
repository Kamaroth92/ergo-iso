#!/usr/bin/env bash

set -e -x

PACKAGES="
    ubuntu-server
    ubuntu-drivers-common
    linux-image-generic-hwe-$DISTRO_BASE_VERSION
    casper
    efibootmgr
    initramfs-tools
    debconf-utils
"

PACKAGES+="
    nano
    jq
"

apt-get update --yes
apt-get upgrade --yes --allow-downgrades
apt-get install --yes $PACKAGES
apt-get autoremove --purge -y
apt-get clean -y
