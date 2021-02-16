#!/bin/sh

KCP_USERNAME="${KCP_USERNAME:-"admin"}"
 KCP_PASSWORD="${KCP_PASSWORD:-"password"}"
KCP_URL="${KCP_URL:-"https://kcp.example.com"}"

KCP_SPACE="devops"
KCP_CLUSTER="${1:-"devops-demo-us-east-1"}"

echo "KCP_CLUSTER=${KCP_CLUSTER}"

# Authenticate with Kublr Control Plane

eval "$(curl -s \
  -d "grant_type=password" \
  -d "scope=openid" \
  -d "client_id=kublr-ui" \
  -d "username=${KCP_USERNAME}" \
  -d "password=${KCP_PASSWORD}" \
  "${KCP_URL}/auth/realms/kublr-ui/protocol/openid-connect/token" | \
  jq -r '"REFRESH_TOKEN="+.refresh_token,"TOKEN="+.access_token,"ID_TOKEN="+.id_token')"

# Download Kubernetes kubeconfig file

curl -k -s -XGET -H "Authorization: Bearer ${TOKEN}" \
  "${KCP_URL}/api/spaces/${KCP_SPACE}/cluster/${KCP_CLUSTER}/admin-config" > \
  "config-${KCP_CLUSTER}.yaml"

export KUBECONFIG="$(pwd)/config-${KCP_CLUSTER}.yaml"

echo "KUBECONFIG at config-${KCP_CLUSTER}.yaml"
