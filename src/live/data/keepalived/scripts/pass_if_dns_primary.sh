#!/usr/bin/env bash

primaryVIP=%PRIMARYVIP% #$VAR_keepalivedVIPAddressDNS1
secondaryVIP=%SECONDARYVIP% #$VAR_keepalivedVIPAddressDNS2
ipAddress=%IPADDRESS% #$VAR_ipAddress
user="%USER%" #admin
password="%PASSWORD%" #delacroix
port=%PORT% #80

LOCAL_TOKEN=$(curl -s "http://localhost:$port/api/user/login?user=admin&pass=$password&includeInfo=true" | jq -r '.token')
if [ -z "${CLUSTER_TOKEN}" ]; then
    echo "Could not get cluster token from local instance"
    exit 1
fi

CLUSTER_STATE=$(curl -s "http://localhost:$port/api/admin/cluster/state?token=$LOCAL_TOKEN")
CLUSTER_INITALISED=$(echo $CLUSTER_STATE | jq -r '.response.clusterInitialized')
if [ "$CLUSTER_INITALISED" != "true" ]; then
    echo "DNS server found at localhost but no cluster has been initalized"
    exit 1
fi

PRIMARY_IP=$(echo $CLUSTER_STATE | jq -r '.response.clusterNodes[] | select(.type=="Primary") | .ipAddresses[0]')
if [ "$PRIMARY_IP" == "$ipAddress" ]; then
    echo "This node is the primary node"
    exit 0
fi

echo "Cluster exists but this node is not the primary node."
exit 1