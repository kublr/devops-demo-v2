# Restore TLS/HTTPS certificates/keys

kubectl apply -f "certificates-${DOMAIN}.json"
kubectl -n devops delete --all certificaterequests,certificates,challenges,orders
