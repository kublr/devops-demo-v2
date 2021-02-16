# Prepare common env vars to use

DOMAIN="${1:-devops-demo-us-east-1.workshop.kublr.com}"

NURL=https://nexus.$DOMAIN
NPASWD=admin123

JURL=https://jenkins.$DOMAIN

echo "DOMAIN=${DOMAIN}"
echo "NURL=${NURL}"
echo "JURL=${JURL}"
