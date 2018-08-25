#!/bin/bash -exu

# on codebuild make sure we use the bin/jets that was checked out
set +u
if [ -n "$CODEBUILD_SRC_DIR" ]; then
  cp .codebuild/bin/jets /usr/local/bin/jets
  chmod a+x /usr/local/bin/jets
  export PATH=/usr/local/bin:$PATH
  which jets
fi

# Locally set the CODEBUILD_SRC_DIR to make script simpler
# Do this before the cd-ing into the newly created directory.
if [ -z $CODEBUILD_SRC_DIR ]; then
  CODEBUILD_SRC_DIR=$(pwd)
fi
set -u

APP_NAME=demo$(date +%s)
jets new $APP_NAME # jets new runs bundle and webpacker:install
cd $APP_NAME

cat >.env.development <<EOL
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DB_HOST=$DB_HOST
EOL
# IE: replace demo with demo1535227161 in case locally using demo and forget to set
perl -i -pe "s/DB_NAME=demo/DB_NAME=${APP_NAME}_dev/" .env.development
# Make sure database env vars matches whats in the file
eval $(cat .env.development | sed 's/^/export /')
# Make sure that nothing is .env.development.remote, dont want to use it for this case
cp /dev/null .env.development.remote

jets generate scaffold Post title:string
# The DB_ environment variables are set up in the circleci environment variables
# website GUI under project settings
jets db:create db:migrate

jets deploy

APP_URL=$(jets url)
cat > jets.postman_environment.json <<EOL
{
  "id": "f50e05e5-c6dd-4707-9270-82c706b2bcef",
  "name": "Jets Test1",
  "values": [
    {
      "key": "BASE_URL",
      "value": "${APP_URL}/",
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

cp $CODEBUILD_SRC_DIR/.codebuild/jets.postman_collection.json .

npm install -g newman
newman run jets.postman_collection.json -e jets.postman_environment.json

# cleanup the database
jets db:drop

# delete jets project
jets delete --sure --no-wait