#!/usr/bin/env bash

keepalived_config=/etc/keepalived/keepalived.conf

sed -i "s|%INTERFACE%|$VAR_keepalivedInterface|g" $keepalived_config
sed -i "s|%PRIORITY%|$VAR_keepalivedPriority|g" $keepalived_config
sed -i "s|%VIRTUAL_IP_ADDRESS_KUBE%|$VAR_keepalivedVIPAddressKube|g" $keepalived_config
sed -i "s|%VIRTUAL_IP_ADDRESS_DNS1%|$VAR_keepalivedVIPAddressDNS1|g" $keepalived_config
sed -i "s|%VIRTUAL_IP_ADDRESS_DNS2%|$VAR_keepalivedVIPAddressDNS2|g" $keepalived_config
# sed -i "s|%ID%|$VAR_keepalivedVirtualRouterID|g" $keepalived_config

echo "Replaced variables in $keepalived_config"
systemctl enable --now keepalived
