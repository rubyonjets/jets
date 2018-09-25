#!/bin/bash -eu

# NOTE: Script assumes that demo and jets folder are in your CDPATH

set +u
if [ -z "$BASE_URL" ]; then
  echo "Please set the BASE_URL env var. Example:"
  echo "  export BASE_URL=https://t0a00hokcj.execute-api.us-west-2.amazonaws.com/dev"
  exit 1
fi
set -u

# check if `jets server` is running
# https://serverfault.com/questions/562524/bash-script-to-check-if-a-public-https-site-is-up
if ! curl -s --head  --request GET "$BASE_URL" | grep "HTTP/2 200" > /dev/null; then
  echo "The application does not seem to be up. Please check that you've deployed to it."
  echo "And then try running this script again."
  exit 1
fi

# Assume demo project has been created
cd demo
# Create a data record that the postman tests assumes to exist.  The postman collection deletes this record.
JETS_ENV_REMOTE=1 jets runner 'Post.create(id: 1) unless Post.find_by(id: 1)'
JETS_ENV_REMOTE=1 jets runner 'Post.create(id: 2) unless Post.find_by(id: 2)'

# Integration postman script lives in jets
cd jets

cat > /tmp/postman-environment.json <<EOL
{
  "id": "f50e05e5-c6dd-4707-9270-82c706b2bcef",
  "name": "Jets Test1",
  "values": [
    {
      "key": "BASE_URL",
      "value": "${BASE_URL}/",
      "description": "",
      "type": "text",
      "enabled": true
    }
  ],
  "_postman_variable_scope": "environment",
  "_postman_exported_at": "2018-08-06T01:39:56.523Z",
  "_postman_exported_using": "Postman/6.2.3"
}
EOL

newman run spec/integration/fixtures/postman/collection.json -e /tmp/postman-environment.json