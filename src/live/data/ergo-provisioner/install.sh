#!/usr/bin/env bash

set -e -x

PROVISIONER_PATH=/ergo/provisioner
PROVISIONER_CONFIGS=$PROVISIONER_PATH/provisioner.d
PROVISIONER_FILES=$PROVISIONER_PATH/files
export PROVISIONER_CONFIGS

mkdir -p $PROVISIONER_PATH
mkdir $PROVISIONER_CONFIGS
mkdir $PROVISIONER_FILES

cp $FILES_DIR/ergo-provisioner/ergo-provisioner.sh $PROVISIONER_PATH
chmod +x $PROVISIONER_PATH/ergo-provisioner.sh

cp $FILES_DIR/ergo-provisioner/ergo-provisioner.service /etc/systemd/system/ergo-provisioner.service
systemctl enable ergo-provisioner.service

cp -r $FILES_DIR/ergo-provisioner/uuid-node-map.json $PROVISIONER_FILES/uuid-node-map.json
cp -r $FILES_DIR/ergo-provisioner/uuid-node-map.json $PROVISIONER_FILES/uuid-node-map.json

cp $FILES_DIR/ergo-provisioner/provisioner.d/* $PROVISIONER_CONFIGS
