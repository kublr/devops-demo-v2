# Save TLS/HTTPS certificates/keys locally

kubectl get secrets -n devops --field-selector type=kubernetes.io/tls -o json | jq '
  del(.items[].metadata.managedFields)|
  del(.items[].metadata.resourceVersion)|
  del(.items[].metadata.selfLink)|
  del(.items[].metadata.uid)|
  del(.items[].metadata.creationTimestamp)|
  del(.items[].metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"])' > certificates-${DOMAIN}.json
