#!/bin/bash -eux

mkdir -p /usr/local/dynamodb_local
curl -s https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz -o /usr/local/dynamodb_local/dynamodb_local_latest.tar.gz
cd /usr/local/dynamodb_local
tar zxf dynamodb_local_latest.tar.gz

cat > /usr/local/bin/dynamodb-local <<EOL
#!/bin/bash

# for dynamodb-local and dynamodb-admin
# More details: https://github.com/tongueroo/jets/wiki/Dynamodb-Local-Setup-Walkthrough
export AWS_SECRET_ACCESS_KEY=fakekey
export AWS_ACCESS_KEY_ID=fakeid

# Based on: https://github.com/Homebrew/homebrew-cask/blob/master/Casks/dynamodb-local.rb
# I manually extracted out the dynamodb local tar to /opt/dynamodb_local
cd /usr/local/dynamodb_local

exec java -Djava.library.path='./DynamoDBLocal_lib' -jar 'DynamoDBLocal.jar' "$@" 2>&1 &
EOL
chmod a+x /usr/local/bin/dynamodb-local
