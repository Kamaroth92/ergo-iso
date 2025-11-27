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
    dnsutils
    traceroute
    tcpdump
    net-tools
"

PACKAGES+="
    nano
    jq
    iperf3
"

apt-get update --yes
apt-get upgrade --yes --allow-downgrades
apt-get install --yes $PACKAGES
apt-get autoremove --purge -y
apt-get clean -y
