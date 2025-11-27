#!/usr/bin/env bash

if systemctl is-active --quiet "$1"; then
	echo "Service '$1' is active active"
	exit 0
fi

echo "Service '$1' is not active"
exit 1
