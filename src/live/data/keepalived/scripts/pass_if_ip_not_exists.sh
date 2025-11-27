#!/usr/bin/env bash

if ! ip addr show | grep -q "$1" ; then
	echo "IP '$1' does not exist on this node"
	exit 0
fi

echo "IP '$1' exists on this node"
exit 1
