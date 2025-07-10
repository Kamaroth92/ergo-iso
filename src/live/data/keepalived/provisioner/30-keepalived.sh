#!/usr/bin/env bash

keepalived_config=/etc/keepalived/keepalived.conf

sed -i "s|%INTERFACE%|$VAR_keepalivedInterface|g" $keepalived_config
sed -i "s|%PRIORITY%|$VAR_keepalivedPriority|g" $keepalived_config
sed -i "s|%VIRTUAL_IP_ADDRESS%|$VAR_keepalivedVIPAddress|g" $keepalived_config
sed -i "s|%ID%|$VAR_keepalivedVirtualRouterID|g" $keepalived_config

echo "Replaced variables in $keepalived_config"

if [ "$VAR_rke2InstallType" = "server" ]; then
	systemctl enable --now keepalived
fi
