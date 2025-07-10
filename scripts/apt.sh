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
	echo "Acquire::http::Proxy \"${APT_CACHE}\";" >/etc/apt/apt.conf.d/00local-apt-proxy
fi

if [ -n "${UPDATE}" ]; then # Update
	echo "APT: Updating"
	apt-get update -y
fi

if [ -n "${UPGRADE}" ]; then # Upgrade
	echo "APT: Upgrading"
	apt-get upgrade -y --allow-downgrades
fi

if [ -n "${INSTALL}" ]; then
	echo "Installing packages: ${INSTALL}"
	apt-get install -y ${INSTALL}
fi

if [ -n "${PURGE}" ]; then
	echo "Removing packages: ${PURGE}"
	apt-get purge -y ${PURGE}
fi

if [ -n "${AUTOREMOVE}" ]; then
	apt-get autoremove --purge -y
fi

if [ -n "${CLEAN}" ]; then
	apt-get clean -y
fi

rm -rf /tmp/*
rm -f /var/lib/dbus/machine-id
rm -f /etc/apt/apt.conf.d/00local-apt-proxy
