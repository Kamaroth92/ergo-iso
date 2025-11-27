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

sed -i "s|%WEBSERVER_URL%|$PROVISIONING_CONFIG_WEB_URL|g" $PROVISIONER_PATH/ergo-provisioner.sh
if [ -f /work/provisioner-config.json ]; then
  cp /work/provisioner-config.json "$PROVISIONING_CONFIG_EMBEDDED_CHROOT_PATH"
  sed -i "s|%CONFIG_FILE%|$PROVISIONING_CONFIG_EMBEDDED_CHROOT_PATH|g" $PROVISIONER_PATH/ergo-provisioner.sh
else
  sed -i "s|%CONFIG_FILE%||g" $PROVISIONER_PATH/ergo-provisioner.sh
fi

cp $FILES_DIR/ergo-provisioner/provisioner.d/* $PROVISIONER_CONFIGS
