#!/bin/bash -eux
# to find latest releases:
# https://github.com/docker/compose/releases
curl -s -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose