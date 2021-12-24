# TODO: cross-compile for arm64

build:
	podman build -t quay.io/dbaker/tangd:latest-amd64 .

push:
	podman push quay.io/dbaker/tangd:latest-amd64

