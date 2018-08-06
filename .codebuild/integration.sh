#!/bin/bash -exu

cp .codebuild/bin/jets /usr/local/bin/jets
chmod a+x /usr/local/bin/jets
export PATH=/usr/local/bin:$PATH

which jets

APP_NAME=demo$(date +%s)
jets new $APP_NAME # jets new runs bundle and webpacker:install
cd $APP_NAME

cat >>.env.development <<EOL
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DB_HOST=$DB_HOST
EOL

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
jets delete --sure