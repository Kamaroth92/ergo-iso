#!/usr/bin/env bash

set -e

INSTALL_TYPE=""
IS_FIRST_NODE=false
SKIP_START=false
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

rke2_config_dir=/etc/rancher/rke2/config.yaml.d

while [[ $# -gt 0 ]]; do
	case "$1" in
	--install-type | -i)
		INSTALL_TYPE="$2"
		shift 2
		;;
	--is-first-node)
		IS_FIRST_NODE=true
		shift
		;;
	--skip-start)
		SKIP_START=true
		shift
		;;
	*)
		echo "Unknown option: $1"
		exit 1
		;;
	esac
done

if [[ "$INSTALL_TYPE" != "server" && "$INSTALL_TYPE" != "agent" ]]; then
	echo "Error: --install-type must be 'server' or 'agent'"
	exit 1
fi

echo "Reloading RKE2 in the $INSTALL_TYPE role. This may take some time."

if systemctl is-active --quiet rke2-server; then
	systemctl stop rke2-server
fi

if systemctl is-active --quiet rke2-agent; then
	systemctl stop rke2-agent
fi

for f in /etc/rancher/rke2/config.yaml.d/*.yaml; do
	[ -e "$f" ] && mv "$f" "${f}-disabled"
done

if [ "$INSTALL_TYPE" = "server" ]; then
	systemctl enable --now keepalived
	mv $rke2_config_dir/10-rke2-config-server-base.yaml-disabled $rke2_config_dir/10-rke2-config-server-base.yaml
	mv $rke2_config_dir/10-rke2-token.yaml-disabled $rke2_config_dir/10-rke2-token.yaml
	if [ "$IS_FIRST_NODE" = "false" ]; then
		mv $rke2_config_dir/10-rke2-config-server-address.yaml-disabled $rke2_config_dir/10-rke2-config-server-address.yaml
	fi

fi

if [ "$INSTALL_TYPE" = "agent" ]; then
	systemctl disable --now keepalived
	mv $rke2_config_dir/10-rke2-token.yaml-disabled $rke2_config_dir/10-rke2-token.yaml
	mv $rke2_config_dir/10-rke2-config-server-address.yaml-disabled $rke2_config_dir/10-rke2-config-server-address.yaml

fi

if [ "$SKIP_START" = "false" ]; then
	echo "Starting rke2-$INSTALL_TYPE"
	systemctl enable --now rke2-$INSTALL_TYPE
else
	echo "Enabling (but not starting) rke2-$INSTALL_TYPE"
	systemctl enable rke2-$INSTALL_TYPE
fi

echo "Complete. Ensure longhorn has migrated replicas before removing any nodes"
