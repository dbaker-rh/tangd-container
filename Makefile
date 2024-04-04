# TODO: cross-compile for arm64

build:
	podman build -t quay.io/dbaker/tangd:latest-amd64 .

push:
	podman push quay.io/dbaker/tangd:latest-amd64
	# TODO: multi-arch
	podman tag quay.io/dbaker/tangd:latest-amd64 quay.io/dbaker/tangd:latest
	podman push quay.io/dbaker/tangd:latest

