#!/usr/bin/env bash

set -e -x

cp $FILES_DIR/os-installer/ergo-install.sh /ergo/sbin/ergo-install
chmod +x /ergo/sbin/ergo-install
ln -s /ergo/sbin/ergo-install /usr/local/sbin/ergo-install
cat <<EOF >/etc/sudoers.d/ergo-install
administrator ALL = (ALL) NOPASSWD: /usr/local/sbin/ergo-install
EOF

cp $FILES_DIR/os-installer/boot-from-ventoy.sh /ergo/sbin/boot-from-ventoy
chmod +x /ergo/sbin/boot-from-ventoy
ln -s /ergo/sbin/boot-from-ventoy /usr/local/sbin/boot-from-ventoy
cat <<EOF >/etc/sudoers.d/boot-from-ventoy
administrator ALL = (ALL) NOPASSWD: /usr/local/sbin/boot-from-ventoy
EOF
