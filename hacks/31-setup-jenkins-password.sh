# Get Jenkins password from Kubernetes secret

JPWD="$(kubectl get secret --namespace devops jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)"

# Save the password in a file

echo "JPWD='${JPWD}'" > jenkins-pwd-${DOMAIN}.sh
