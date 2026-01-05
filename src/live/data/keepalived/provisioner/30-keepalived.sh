#!/usr/bin/env bash

keepalived_config=/etc/keepalived/keepalived.conf
sed -i "s|%INTERFACE%|$VAR_keepalivedInterface|g" $keepalived_config
sed -i "s|%PRIORITY%|$VAR_keepalivedPriority|g" $keepalived_config
sed -i "s|%VIRTUAL_IP_ADDRESS_KUBE%|$VAR_keepalivedVIPAddressKube|g" $keepalived_config
sed -i "s|%VIRTUAL_IP_ADDRESS_DNS1%|$VAR_keepalivedVIPAddressDNS1|g" $keepalived_config
sed -i "s|%VIRTUAL_IP_ADDRESS_DNS2%|$VAR_keepalivedVIPAddressDNS2|g" $keepalived_config
echo "Replaced variables in $keepalived_config"

pass="delacroix"
port=80
dns_primary_check_script="/etc/keepalived/scripts/pass_if_dns_primary.sh"
sed -i "s|%PRIMARYVIP%|$VAR_keepalivedVIPAddressDNS1|g" $dns_primary_check_script
sed -i "s|%SECONDARYVIP%|$VAR_keepalivedVIPAddressDNS2|g" $dns_primary_check_script
sed -i "s|%IPADDRESS%|$VAR_ipAddress|g" $dns_primary_check_script
sed -i "s|%USER%|admin|g" $dns_primary_check_script
sed -i "s|%PASSWORD%|$pass|g" $dns_primary_check_script
sed -i "s|%PORT%|80|g" $dns_primary_check_script
echo "Replaced variables in $dns_primary_check_script"

systemctl enable --now keepalived
