#!/usr/bin/env bash

rke2_config_dir=/etc/rancher/rke2/config.yaml.d
echo -n $VAR_rke2InstallType >/ergo/vars/INSTALL_RKE2_TYPE

# Replace variables
sed -i "s|%TOKEN%|$VAR_rke2Token|g" $rke2_config_dir/10-rke2-token.yaml-disabled
echo "Replaced variables in $rke2_config_dir/10-rke2-token.yaml-disabled"

sed -i "s|%VIPHOSTNAME%|$VAR_rke2VIPHostName|g" $rke2_config_dir/10-rke2-config-server-base.yaml-disabled
sed -i "s|%VIPADDRESS%|$VAR_keepalivedVIPAddress|g" $rke2_config_dir/10-rke2-config-server-base.yaml-disabled
sed -i "s|%IPADDRESS%|$VAR_ipAddress|g" $rke2_config_dir/10-rke2-config-server-base.yaml-disabled
echo "Replaced variables in $rke2_config_dir/10-rke2-config-server-base.yaml-disabled"

sed -i "s|%VIPADDRESS%|$VAR_keepalivedVIPAddress|g" $rke2_config_dir/10-rke2-config-server-address.yaml-disabled
echo "Replaced variables in $rke2_config_dir/10-rke2-config-server-address.yaml-disabled"

if [ "$VAR_rke2IsFirstNode" = false ]; then
	rke2-switch-install --install-type $VAR_rke2InstallType --skip-start
else
	rke2-switch-install --install-type $VAR_rke2InstallType --is-first-node --skip-start
fi

# Don't start RK2 if the upper filesystem cannot be written to
if mount | grep -q 'upperdir=/cow/upper'; then
	echo "Running immutable upper directory. Skipping rke2-$VAR_rke2InstallType"
else
	echo "Not running with immutable upper directory, continuing"
	systemctl enable --now rke2-$VAR_rke2InstallType.service
fi
