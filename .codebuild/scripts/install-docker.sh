#!/bin/bash -eux

# docker client
# https://docs.docker.com/install/linux/docker-ce/debian/#install-using-the-convenience-script
# Install docker client because we're going to use docker to
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# docker-compose
# to find latest releases:
# https://github.com/docker/compose/releases
curl -s -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose