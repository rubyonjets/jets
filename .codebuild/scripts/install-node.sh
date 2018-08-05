#!/bin/bash -eux
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs
npm install -g yarn
