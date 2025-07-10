#!/usr/bin/env bash

set -e -x

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

if [ -n "$(which dbus-uuidgen)" ]; then
	dbus-uuidgen >/etc/machine-id
	ln -sf /etc/machine-id /var/lib/dbus/machine-id
fi

if [ ! -f /run/systemd/resolve/stub-resolv.conf ]; then
	mkdir -p /run/systemd/resolve
	echo "nameserver 1.1.1.1" >/run/systemd/resolve/stub-resolv.conf
fi

ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

if [ -n ${APT_CACHE} ]; then
	echo Using apt cache: ${APT_CACHE}
	echo "Acquire::http::Proxy \"${APT_CACHE}\";" >/etc/apt/apt.conf.d/00local-apt-proxy
fi

if [ -n ${FILE} ]; then
	echo Running file: $FILE
	source $FILE
elif [ -n ${COMMAND} ]; then
	echo Running command: $COMMAND
	source $COMMAND
else
	echo "Pass a parameter for FILE or COMMAND"
fi

rm -rf /tmp/*
rm -f /var/lib/dbus/machine-id
rm -f /etc/apt/apt.conf.d/00local-apt-proxy
