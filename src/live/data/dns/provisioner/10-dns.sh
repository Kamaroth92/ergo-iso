#!/usr/bin/env bash

primaryVIP=$VAR_keepalivedVIPAddressDNS1
secondaryVIP=$VAR_keepalivedVIPAddressDNS2
ipAddress=$VAR_ipAddress
user="admin"
password=$VAR_dnsAdminPassword
port=80

# Do a simple check to see if the cluster already exists
CLUSTER_TOKEN=$(curl -s "http://$primaryVIP:$port/api/user/login?user=admin&pass=$password&includeInfo=true" | jq -r '.token')

# Check if cluyster is already initialized
IS_INIT = $(curl -s http://$primaryVIP:$port/api/admin/cluster/state?token=$TOKEN | jq -r '.response.clusterInitialized')

PRIMARY_IP = $(curl -s http://$primaryVIP:$port/api/admin/cluster/state?token=$TOKEN | jq -r '.response.clusterNodes[] | select(.type=="Primary") | .ipAddresses[0]')


# Get user token
TOKEN=$(curl -s "http://localhost:5380/api/user/login?user=admin&pass=admin&includeInfo=true" | jq -r '.token')

# Set port to 80
curl "http://localhost:5380/api/settings/set?token=$TOKEN&webServiceHttpPort=$port"

# Change default password
curl "http://localhost:$port/api/user/changePassword?token=$TOKEN&pass=$defaultPassword&newPass=$pass"

# Allow lookups on primary and secondary VIPs
curl "http://localhost:$port/api/settings/set?token=$TOKEN&dnsServerLocalEndPoints=0.0.0.0:53,[::]:53,$primaryVIP:53,$secondaryVIP:53"

curl "http://localhost:$port/api/admin/cluster/initJoin?token=$TOKEN&secondaryNodeIpAddresses=$ipAddress&primaryNodeUrl=http%3A%2F%2F$primaryVIP%3A80&primaryNodeIpAddress=$primaryVIP&primaryNodeUsername=$user&primaryNodePassword=$password"
