# Code Build Commands

## The code definitions are stored in the codebuild s3 bucket.

    aws s3 cp .codebuild/definitions/jets_base.json s3://$S3_BUCKET/codebuild/definitions/jets_base.json
    aws s3 cp .codebuild/definitions/jets_main.json s3://$S3_BUCKET/codebuild/definitions/jets_main.json

## JetsBase

The JetsBase codebuild project projects builds the Docker base image and pushes it to Docker hub.  Here are the commands to manage the codebuild project.

    aws codebuild create-project --cli-input-json file://.codebuild/definitions/jets_base.json
    aws codebuild update-project --cli-input-json file://.codebuild/definitions/jets_base.json

    aws codebuild start-build --project-name JetsBase --source-version codebuild

    aws codebuild batch-get-projects --names JetsBase
    aws codebuild list-builds-for-project --project-name JetsBase

    BUILD_ID=$(aws codebuild list-builds-for-project --project-name JetsBase | jq -r '.ids[0]')
    aws codebuild batch-get-builds --ids $BUILD_ID

    STREAM=$(aws codebuild batch-get-builds --ids $BUILD_ID | jq -r '.builds[0].logs.streamName')
    cw tail -f /aws/codebuild/JetsBase $STREAM

If you want to manually build the Docker base image.  Run:

    docker build -t tongueroo/jets:base -f Dockerfile.base .
    docker push tongueroo/jets:base

## JetsMain

    aws codebuild create-project --cli-input-json file://.codebuild/definitions/jets_main.json
    aws codebuild update-project --cli-input-json file://.codebuild/definitions/jets_main.json

    aws codebuild start-build --project-name JetsMain --source-version codebuild

    aws codebuild batch-get-projects --names JetsMain
    aws codebuild list-builds-for-project --project-name JetsMain

    BUILD_ID=$(aws codebuild list-builds-for-project --project-name JetsMain | jq -r '.ids[0]')
    aws codebuild batch-get-builds --ids $BUILD_ID

    STREAM=$(aws codebuild batch-get-builds --ids $BUILD_ID | jq -r '.builds[0].logs.streamName')
    cw tail -f /aws/codebuild/JetsMain $STREAM

## Run CodeBuild Locally

    time docker run -it -v /var/run/docker.sock:/var/run/docker.sock \
      -e "IMAGE_NAME=tongueroo/jets:base" \
      -e "ARTIFACTS=/tmp/artifacts" \
      -e "SOURCE=/home/ec2-user/environment/jets" \
      -e "DB_USER=$DB_USER" \
      -e "DB_PASS=$DB_PASS" \
      -e "DB_HOST=$DB_HOST" \
      amazon/aws-codebuild-local

## Run ingreration.sh

Can run the integration.sh test locally by running:

    export DB_NAME=demo
    export DB_USER=dbuser
    export DB_PASS=dbpass
    export DB_HOST=rdshost
    .codebuild/integration.sh

Note, you'll need to use a real RDS db instance.  Make sure DATABASE_URL is not set, this is working with the DB_* vars.