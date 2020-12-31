---
title: Debugging CloudFormation
---

Underneath the hood, CloudFormation is used to provision AWS resources. This is discussed in this [podcast](http://5by5.tv/rubyonrails/253) interview.  Jets actually creates several CloudFormation stacks. It creates a parent stack and a bunch of nested child stacks.  Jets manages this all for you.

So if a [jets deploy](http://rubyonjets.com/reference/jets-deploy/) fails, you likely want to check out the CloudFormation console for errors. Particularly, usually checking the child stack with the error instead of the parent stack is the most helpful.

## Example

The `jets deploy` command itself logs the CloudFormation of the parent stack.  Here's what an example of a deploy with an error:

    $ jets deploy
    ...
    Deploying CloudFormation stack with jets app!
    03:20:27AM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack demo-dev User Initiated
    ...
    03:20:44AM UPDATE_FAILED AWS::CloudFormation::Stack JetsPreheatJob Embedded stack arn:aws:cloudformation:us-west-2:112233445566:stack/demo-dev-JetsPreheatJob-IXX3J912KGKS/f4fec860-1871-11e9-94d5-0a57e06cb5fc was not successfully updated. Currently in UPDATE_ROLLBACK_IN_PROGRESS with reason: The following resource(s) failed to update: [WarmLambdaFunction, TorchLambdaFunction].
    03:20:45AM UPDATE_FAILED AWS::CloudFormation::Stack JetsPublicController Resource update cancelled
    03:20:45AM UPDATE_FAILED AWS::CloudFormation::Stack PostsController Resource update cancelled
    ...
    03:21:43AM UPDATE_ROLLBACK_COMPLETE AWS::CloudFormation::Stack demo-dev
    Stack rolled back: UPDATE_ROLLBACK_COMPLETE
    ...

The parent stack is reporting that the main error is on the `JetsPreheatJob Embedded stack` nested child stack.  You can check on this error in CloudFormation console by clicking on the child stack and will find something like this:

![](/img/docs/debug/cloudformation-child-stack-error.png)

You can see here that the error is because the user does not have the necessary IAM permission. In this case, giving the user the [Minimal Deploy IAM Policy]({% link _docs/extras/minimal-deploy-iam.md %}) will resolve the issue.

## New Child Stacks Deleted

When a child stack is created for the very first time and happens to fail, CloudFormation will roll back the child stack and delete it. This makes it tricky for those who don't yet realize this because the error message is gone by the time they check. In this case, you have to refresh the CloudFormation console during a deploy to see it and capture that.

You may want to try incrementally debugging it. First, create a simple class with just one method and get that deployed successfully. And then add your full logic and deploy again. With this approach, the rolled back child stack remain intact and you can see the error message post deploy.

