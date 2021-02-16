# Enable anonymous users in nexus

curl -X PUT -H 'content-type:application/json' -u "admin:$NPASWD" -w '\n%{http_code}\n' -d '@-' \
    $NURL/service/rest/v1/security/anonymous <<EOF
{"enabled":true,"userId":"anonymous","realmName":"NexusAuthorizingRealm"}
EOF

# Enable DockerToken security realm

curl -X GET -H 'content-type:application/json' -s -u "admin:$NPASWD" \
    $NURL/service/rest/v1/security/realms/active | \
\
jq 'map(select(. != "DockerToken")) + ["DockerToken"]' | \
\
curl -X PUT -H 'content-type:application/json' -u "admin:$NPASWD" -w '\n%{http_code}\n' -d '@-' \
    $NURL/service/rest/v1/security/realms/active

# Create a hosted docker repository

curl -X POST -H 'content-type:application/json' -u "admin:$NPASWD" -w '\n%{http_code}\n' -d '@-' \
    $NURL/service/rest/v1/repositories/docker/hosted <<EOF
{
    "name" : "docker-hosted",
    "online" : true,
    "storage" : {
    "blobStoreName" : "default",
    "strictContentTypeValidation" : true,
    "writePolicy" : "ALLOW"
    },
    "docker" : {
    "v1Enabled" : false,
    "forceBasicAuth" : false,
    "httpPort" : 5003
    }
}
EOF
