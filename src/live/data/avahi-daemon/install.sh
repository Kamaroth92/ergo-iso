#!/usr/bin/env bash

set -e -x

apt-get install --yes avahi-daemon avahi-utils
cp $FILES_DIR/avahi-daemon/ergo.service /etc/avahi/services/ergo.service
