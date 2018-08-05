Code Build Commands:

    aws codebuild create-project --cli-input-json file://.codebuild/definitions/jets_base_build.json
    aws codebuild update-project --cli-input-json file://.codebuild/definitions/jets_base_build.json

    aws codebuild start-build --project-name JetsBaseBuild --source-version codebuild

    aws codebuild batch-get-projects --names JetsBaseBuild
    aws codebuild list-builds-for-project --project-name JetsBaseBuild

    BUILD_ID=$(aws codebuild list-builds-for-project --project-name JetsBaseBuild | jq -r '.ids[0]')
    aws codebuild batch-get-builds --ids $BUILD_ID

    STREAM=$(aws codebuild batch-get-builds --ids $BUILD_ID | jq -r '.builds[0].logs.streamName')
    cw tail -f /aws/codebuild/JetsBaseBuild $STREAM