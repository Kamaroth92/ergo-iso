#!/usr/bin/env bash

netplan_config_dir=/etc/netplan

if [ -z "$VAR_ipAddress" ]; then
	rm $netplan_config_dir/10-primary.yaml
	rm $netplan_config_dir/20-iot-vlan.yaml
else
	sed -i "s|%IPADDRESS_1%|$VAR_ipAddress|g" $netplan_config_dir/10-primary.yaml
	sed -i "s|%INTERFACE_1%|$VAR_keepalivedInterface|g" $netplan_config_dir/10-primary.yaml
	sed -i "s|%DNS_SEARCH_DOMAIN%|$VAR_dnsSearchDomain|g" $netplan_config_dir/10-primary.yaml

	sed -i "s|%IOTVLAN_IPADDRESS%|$VAR_iotVlanAddress|g" $netplan_config_dir/20-iot-vlan.yaml
	sed -i "s|%INTERFACE_1%|$VAR_keepalivedInterface|g" $netplan_config_dir/20-iot-vlan.yaml
	sed -i "s|%DNS_SEARCH_DOMAIN%|$VAR_dnsSearchDomain|g" $netplan_config_dir/20-iot-vlan.yaml
fi

echo "Replaced variables in $netplan_config_dir files"
netplan apply
echo "Applied netplan config"
