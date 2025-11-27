#!/usr/bin/env bash

if ! mount | grep -q 'upperdir=/cow/upper'; then
	echo "Not running in live environment"
	exit 0
fi

echo "Running in live environment"
exit 1
