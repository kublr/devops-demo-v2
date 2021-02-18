# Prepare common env vars to use

echo "The script will set all required environment variables for the follow-up scripts."
echo "By default it will set everything up for a cluster name 'devops-demo-us-east-1' and"
echo "domain name 'devops-demo-us-east-1.workshop.kublr.com'."
echo
echo "You can run it as '. devops-demo/hacks/00-prep-env.sh my-cluster my-domain.com' to"
echo "configure scripts for other domains."
echo
echo "The scrips also require KCP_USERNAME, KCP_PASSWORD, and KCP_URL environment variables"
echo "configured correctly to work."
echo

KCP_USERNAME="${KCP_USERNAME:-"admin"}"
# KCP_PASSWORD=
# KCP_URL="${KCP_URL-"https://kcp.example.com"}"

KCP_SPACE="devops"
KCP_CLUSTER="${1:-"devops-demo-us-east-1"}"

DOMAIN="${2:-"${KCP_CLUSTER}.workshop.kublr.com"}"

NURL=https://nexus.$DOMAIN
NPASWD=admin123

JURL=https://jenkins.$DOMAIN

if [ -z "${KCP_URL}" ] ; then
    echo "ERROR: KCP_URL environment variable is not defined"
    return 1
fi

if [ -z "${KCP_PASSWORD}" ] ; then
    echo "ERROR: KCP_PASSWORD environment variable is not defined"
    return 1
fi

echo "KCP_URL=${KCP_URL}"
echo "KCP_USERNAME=${KCP_USERNAME}"

echo "KCP_CLUSTER=${KCP_CLUSTER}"
echo "DOMAIN=${DOMAIN}"

echo "NURL=${NURL}"
echo "JURL=${JURL}"
