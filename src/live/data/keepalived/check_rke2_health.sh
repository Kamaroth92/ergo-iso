#!/usr/bin/env bash

# Check if the RKE2 server is active
if ! systemctl is-active --quiet rke2-server; then
	echo "rke2-server not active"
	exit 1
fi

# Check if this node is Ready in the cluster
NODE_NAME=$(hostname)
if ! kubectl get node "$NODE_NAME" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q True; then
	echo "Node is not Ready"
	exit 1
fi

exit 0
