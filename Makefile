
build:
	podman build -t quay.io/dbaker/tangd:latest .

push:
	podman push quay.io/dbaker/tangd:latest

