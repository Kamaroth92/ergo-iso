#!/bin/bash

set -e -x

user=administrator
pass=$ADMINISTRATOR_USER_PASSWORD

adduser --gecos "" --disabled-password $user
echo "$user:$pass" | chpasswd

usermod -aG sudo $user
mkhomedir_helper $user

mkdir -p /home/$user/.ssh
echo $ADMINISTRATOR_SSH_KEY >/home/$user/.ssh/authorized_keys

# Allow administrator to reboot and pxe boot without passaword
cat <<EOF >/etc/sudoers.d/$user
$user ALL = (ALL) NOPASSWD: /sbin/poweroff, /sbin/reboot, /sbin/shutdown
EOF

echo "export PATH=\"\$PATH:/ergo/bin\"" >>/home/$user/.bashrc
