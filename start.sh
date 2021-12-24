#!/bin/sh
set -e

# Optionally create new keys if none exist
if [ ! -z "$CREATE_TANG_KEYS" ]; then
  grep -r -q '"sign"' /var/db/tang || /usr/libexec/tangd-keygen /var/db/tang
fi

# Start listener
set -x
socat tcp-l:7500,reuseaddr,fork exec:"/usr/libexec/tangd /var/db/tang"

