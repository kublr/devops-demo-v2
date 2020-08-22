include main.properties

IMAGE = index.docker.io/kublr/spin-kub-v2-demo
TAG = v1.0-manual-068

build:
	docker build -t $(IMAGE):$(TAG) .
.PHONY: build

push:
	docker -- push $(IMAGE):$(TAG)
.PHONY: push
