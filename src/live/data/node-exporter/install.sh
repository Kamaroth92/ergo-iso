#!/usr/bin/env bash

set -e -x

VERSION=1.9.1
wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz
tar xvfz node_exporter-${VERSION}.linux-amd64.tar.gz
cp node_exporter-${VERSION}.linux-amd64/node_exporter /ergo/bin

cp $FILES_DIR/node-exporter/node-exporter.service /etc/systemd/system
systemctl enable node-exporter.service
