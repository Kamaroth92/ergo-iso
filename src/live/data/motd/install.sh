#!/usr/bin/env bash

set -e -x

rm /etc/update-motd.d/*
cp $FILES_DIR/motd/motd/* /etc/update-motd.d

sed -i "s|%DISTRO_NAME%|$(cat /ergo/vars/DISTRO_NAME)|g" /etc/update-motd.d/10-header
sed -i "s|%BUILD_TIME%|$(cat /ergo/vars/BUILD_TIME)|g" /etc/update-motd.d/10-header

sed -i "s|%DISTRO_NAME%|$(cat /ergo/vars/DISTRO_NAME)|g" /etc/update-motd.d/20-install-instructions

chmod +x /etc/update-motd.d/*-*
