#!/usr/bin/env bash

set -e -x

apt-get install --yes ufw
ufw enable

# RKE2 Server node ports
ufw allow 6443/tcp
ufw allow 9345/tcp
ufw allow 2379:2381/tcp

# RKE2 All node ports
ufw allow 10250/tcp
ufw allow 30000:32767/tcp

# Cilium ports
ufw allow 4240/tcp
ufw allow 4244/tcp
ufw allow 9962/tcp
ufw allow 9965/tcp
ufw allow 51871/udp
ufw allow 8472/udp

# Others
ufw allow 6379 comment 'redis'
ufw allow in from 192.168.10.0/24 to 224.0.0.18 comment 'keepalived multicast'
ufw allow 22 comment 'ssh'
ufw allow 9200/tcp comment 'prometheus node exporter'
