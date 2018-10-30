This builds the project and deploys it AWS Lambda. The deployment is mainly handled by CloudFormation.  To check on the status of the deploy you can also check the CloudFormation console.

![](http://rubyonjets.com/img/cli/deploy-cloudformation-status.png)

## Example

    $ jets deploy
    Deploying to Lambda demo-dev environment...
    => Compling assets in current project directory
    => Copying current project directory to temporary build area: /tmp/jets/demo/app_root
    => Tidying project: removing ignored files to reduce package size.
    => Generating node shims in the handlers folder.
    => Bundling: running bundle install in cache area: /tmp/jets/demo/cache.
    => Setting up a vendored copy of ruby.
    => Replacing compiled gems with AWS Lambda Linux compiled versions.
    Creating zip file.
    => cd /tmp/jets/demo/app_root && zip --symlinks -rq /tmp/jets/demo/code/code-temp.zip .
    Building CloudFormation templates.
    Deploying CloudFormation stack with jets app!
    Uploading /tmp/jets/demo/code/code-7169d0ac.zip (88.8 MB) to S3
    Time to upload code to s3: 1s
    Deploying CloudFormation stack with jets app!
    02:08:20AM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack demo-dev User Initiated
    02:08:23AM CREATE_IN_PROGRESS AWS::CloudFormation::Stack ApiGateway
    ...
    02:08:48AM CREATE_IN_PROGRESS AWS::CloudFormation::Stack PostsController
    02:10:03AM UPDATE_COMPLETE AWS::CloudFormation::Stack demo-dev
    Stack success status: UPDATE_COMPLETE
    Time took for stack deployment: 1m 46s.
    Prewarming application.
    API Gateway Endpoint: https://ewwnealfk0.execute-api.us-west-2.amazonaws.com/dev/
    $
