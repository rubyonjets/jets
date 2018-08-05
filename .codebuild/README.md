# Code Build Commands

## The code definitions are stored in the codebuild s3 bucket.

    aws s3 cp .codebuild/definitions/jets_base.json s3://$S3_BUCKET/codebuild/definitions/jets_base.json
    aws s3 cp .codebuild/definitions/jets_main.json s3://$S3_BUCKET/codebuild/definitions/jets_main.json

## JetsBase

    aws codebuild create-project --cli-input-json file://.codebuild/definitions/jets_base.json
    aws codebuild update-project --cli-input-json file://.codebuild/definitions/jets_base.json

    aws codebuild start-build --project-name JetsBase --source-version codebuild

    aws codebuild batch-get-projects --names JetsBase
    aws codebuild list-builds-for-project --project-name JetsBase

    BUILD_ID=$(aws codebuild list-builds-for-project --project-name JetsBase | jq -r '.ids[0]')
    aws codebuild batch-get-builds --ids $BUILD_ID

    STREAM=$(aws codebuild batch-get-builds --ids $BUILD_ID | jq -r '.builds[0].logs.streamName')
    cw tail -f /aws/codebuild/JetsBase $STREAM

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
  amazon/aws-codebuild-local
