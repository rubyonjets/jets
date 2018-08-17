The CloudFormation stack status info. Essentially the events of the CloudFormation stack since the last update. If the CloudFormation stack is currently updating, this will live tail the events logs.

## Example

    $ jets status
    The current status for the stack demo-dev is UPDATE_COMPLETE
    Stack events:
    05:21:42AM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack demo-dev User Initiated
    05:21:45AM CREATE_IN_PROGRESS AWS::CloudFormation::Stack ApiGateway
    ...
    05:23:22AM CREATE_COMPLETE AWS::CloudFormation::Stack JetsPreheatJob
    05:23:25AM UPDATE_COMPLETE_CLEANUP_IN_PROGRESS AWS::CloudFormation::Stack demo-dev
    05:23:25AM UPDATE_COMPLETE AWS::CloudFormation::Stack demo-dev
    $