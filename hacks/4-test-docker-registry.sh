# Test docker registry by pushing and pulling a small image there

docker pull alpine
docker tag alpine registry.$DOMAIN/alpine/alpine
docker login      registry.$DOMAIN -u admin -p "$NPASWD"
docker push       registry.$DOMAIN/alpine/alpine
docker logout     registry.$DOMAIN
docker rmi        registry.$DOMAIN/alpine/alpine
docker pull       registry.$DOMAIN/alpine/alpine
