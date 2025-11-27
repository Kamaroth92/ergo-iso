#!/usr/bin/env bash

set -e -x

apt-get install --yes openssh-server openssh-client

mkdir -p /etc/ssh/sshd_config.d/
cp $FILES_DIR/sshd/60-ergo.conf /etc/ssh/sshd_config.d/
