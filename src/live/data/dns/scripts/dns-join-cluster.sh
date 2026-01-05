#!/usr/bin/env bash

set -e -x

primaryVIP=%PRIMARYVIP% #$VAR_keepalivedVIPAddressDNS1
secondaryVIP=%SECONDARYVIP% #$VAR_keepalivedVIPAddressDNS2
ipAddress=%IPADDRESS% #$VAR_ipAddress
user="%USER%" #admin
password="%PASSWORD%" #delacroix
port=%PORT% #80

if mount | grep -q 'upperdir=/cow/upper'; then
    echo "Running in live environment, cannot join cluster"
    exit 1
fi

CLUSTER_TOKEN=$(curl -s "http://$primaryVIP:$port/api/user/login?user=admin&pass=$password&includeInfo=true" | jq -r '.token')
if [ -z "${CLUSTER_TOKEN}" ]; then
    echo "Could not get cluster token from primary VIP '$primaryVIP'"
    exit 1
fi  

CLUSTER_STATE=$(curl -s "http://$primaryVIP:$port/api/admin/cluster/state?token=$CLUSTER_TOKEN")
CLUSTER_INITALISED=$(echo $CLUSTER_STATE | jq -r '.response.clusterInitialized')
if [ "$CLUSTER_INITALISED" != "true" ]; then
    echo "DNS server found at '$primaryVIP' but no cluster has been initalized"
    exit 1
fi

PRIMARY_IP=$(echo $CLUSTER_STATE | jq -r '.response.clusterNodes[] | select(.type=="Primary") | .ipAddresses[0]')
if [ "$PRIMARY_IP" == "$ipAddress" ]; then
    echo "This node is the primary node"
    exit 1
fi

# Add node to existing cluster
LOCAL_TOKEN=$(curl -s "http://localhost:$port/api/user/login?user=admin&pass=$password&includeInfo=true" | jq -r '.token')
if [ -z "${LOCAL_TOKEN}" ]; then
    echo "Could not get cluster token from localhost"
    exit 1
fi

LOCAL_STATE=$(curl -s "http://localhost:$port/api/admin/cluster/state?token=$LOCAL_TOKEN")
LOCAL_INITALISED=$(echo $LOCAL_STATE | jq -r '.response.clusterInitialized')
LOCAL_INITALISED_CLUSTER_DOMAIN=$(echo $LOCAL_STATE | jq -r '.response.clusterDomain')

if [ "$LOCAL_INITALISED" == "true" ]; then
    echo "This node is already part of a cluster '$LOCAL_INITALISED_CLUSTER_DOMAIN'"
    exit 1
fi

echo "Cluster initalized but this node is not the primary node. Joining cluster '$primaryVIP'"
JOIN_STATUS=$(curl -s "http://localhost:$port/api/admin/cluster/initJoin?token=$LOCAL_TOKEN&secondaryNodeIpAddresses=$ipAddress&primaryNodeUrl=http%3A%2F%2F$primaryVIP%3A80&primaryNodeIpAddress=$primaryVIP&primaryNodeUsername=$user&primaryNodePassword=$password" | jq -r '.status')
echo "Join status: $JOIN_STATUS"