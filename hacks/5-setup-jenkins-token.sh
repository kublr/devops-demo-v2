# Prepare Jenkins authentication env vars

# Get Jenkins password from Kubernetes secret

JPWD="$(kubectl get secret --namespace devops jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)"

# Save the password in a file

echo "JPWD='${JPWD}'" > jenkins-pwd-${DOMAIN}.sh

# Create a token for Jenkins API scription

JCRUMB=$(curl --silent --show-error --fail -X GET  -c cookies.txt -u "admin:$JPWD" \
    $JURL/crumbIssuer/api/json | jq -r .crumb)

JTOKEN=$(curl --silent --show-error --fail -X POST -b cookies.txt -u "admin:$JPWD" \
    -H "Jenkins-Crumb: $JCRUMB" \
    $JURL/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=\devops-demo | jq -r .data.tokenValue)

# Save the token in a file

echo "JTOKEN='${JTOKEN}'" > jenkins-token-${DOMAIN}.sh
