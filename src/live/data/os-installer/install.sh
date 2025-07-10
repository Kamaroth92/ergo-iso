#!/usr/bin/env bash

set -e -x

cp $FILES_DIR/os-installer/ergo-install.sh /ergo/sbin/ergo-install
chmod +x /ergo/sbin/ergo-install
ln -s /ergo/sbin/ergo-install /usr/local/sbin/ergo-install
cat <<EOF >/etc/sudoers.d/ergo-install
administrator ALL = (ALL) NOPASSWD: /usr/local/sbin/ergo-install
EOF
