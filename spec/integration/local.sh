#!/bin/bash

# NOTE: Script assumes that demo and jets folder are in your CDPATH

# check if `jets server` is running
# https://serverfault.com/questions/562524/bash-script-to-check-if-a-public-https-site-is-up
if ! curl -s --head  --request GET http://localhost:8888 | grep "200 OK" > /dev/null; then
  echo "The jets server does not seem to be up. Please run: jets server"
  echo "And then try running this script again."
  exit 1
fi

# Assume demo project has been created
cd demo
# Create a data record that the postman tests assumes to exist.  The postman collection deletes this record.
jets runner 'Post.create(id: 1) unless Post.find_by(id: 1)'
jets runner 'Post.create(id: 2) unless Post.find_by(id: 2)'

# Integration postman script lives in jets
cd jets
newman run spec/integration/fixtures/postman/collection.json -e spec/integration/fixtures/postman/environment.json