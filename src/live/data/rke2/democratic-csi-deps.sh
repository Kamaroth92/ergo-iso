#!/usr/bin/env bash

set -e -x

# NFS and CIFS
apt-get install --yes nfs-common cifs-utils

# iSCSI
apt-get install --yes open-iscsi lsscsi sg3-utils multipath-tools scsitools
