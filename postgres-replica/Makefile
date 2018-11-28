image_name = dalpo/postgres-replica
image_version = 9.6-alpine.2

.PHONY: build
build:
	echo "Build new docker image"
	docker build -t "${image_name}:${image_version}" .

.PHONY: push
push:
	docker push "${image_name}:${image_version}"
