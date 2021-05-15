#!/bin/sh
set -e
#mkdir -p /var/db/tang /var/cache/tang
#grep -r -q '"sign"' /var/db/tang || /usr/libexec/tangd-keygen /var/db/tang
#/usr/libexec/tangd-update /var/db/tang /var/cache/tang

socat tcp-l:8080,reuseaddr,fork exec:"/usr/libexec/tangd /var/db/tang"

