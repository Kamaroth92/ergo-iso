#!/usr/bin/env bash

pass="delacroix"
port=80
dns_join_cluster_service="/ergo/bin/dns-join-cluster.sh"
sed -i "s|%PRIMARYVIP%|$VAR_keepalivedVIPAddressDNS1|g" $dns_join_cluster_service
sed -i "s|%SECONDARYVIP%|$VAR_keepalivedVIPAddressDNS2|g" $dns_join_cluster_service
sed -i "s|%IPADDRESS%|$VAR_ipAddress|g" $dns_join_cluster_service
sed -i "s|%USER%|admin|g" $dns_join_cluster_service
sed -i "s|%PASSWORD%|$pass|g" $dns_join_cluster_service
sed -i "s|%PORT%|80|g" $dns_join_cluster_service

# Change defaults
TOKEN=$(curl -s "http://localhost:5380/api/user/login?user=admin&pass=admin&includeInfo=true" | jq -r '.token')
curl "http://localhost:5380/api/settings/set?token=$TOKEN&dnsServerDomain=$VAR_name&webServiceHttpPort=$port&dnsServerLocalEndPoints=0.0.0.0:53,[::]:53,$VAR_keepalivedVIPAddressDNS1:53,$VAR_keepalivedVIPAddressDNS2:53"
curl "http://localhost:5380/api/user/changePassword?token=$TOKEN&pass=admin&newPass=$pass"