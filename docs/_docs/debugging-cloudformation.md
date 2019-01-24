---
title: Debugging CloudFormation
---

Underneath the hood, CloudFormation is used to provision AWS resources. This is discussed in this [podcast](http://5by5.tv/rubyonrails/253) interview.  Jets actually creates several CloudFormation stacks. It creates a parent stack, and a bunch of nested child stacks.  Jets manages this all for you.

So if a [jets deploy](http://rubyonjets.com/reference/jets-deploy/) fails, you likely want to check out the CloudFormation console for errors. Particularly, checking the child stack with the error is the most helpful.

## Example

The `jets deploy` command itself logs the CloudFormation of the parent stack.  Here's what an example of a deploy with an error:

    $ jets deploy
    ...
    Deploying CloudFormation stack with jets app!
    03:20:27AM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack demo-dev User Initiated
    ...
    03:20:44AM UPDATE_FAILED AWS::CloudFormation::Stack JetsPreheatJob Embedded stack arn:aws:cloudformation:us-west-2:536766270177:stack/demo-dev-JetsPreheatJob-IXX3J912KGKS/f4fec860-1871-11e9-94d5-0a57e06cb5fc was not successfully updated. Currently in UPDATE_ROLLBACK_IN_PROGRESS with reason: The following resource(s) failed to update: [WarmLambdaFunction, TorchLambdaFunction].
    03:20:45AM UPDATE_FAILED AWS::CloudFormation::Stack JetsPublicController Resource update cancelled
    03:20:45AM UPDATE_FAILED AWS::CloudFormation::Stack PostsController Resource update cancelled
    ...
    03:21:43AM UPDATE_ROLLBACK_COMPLETE AWS::CloudFormation::Stack demo-dev
    Stack rolled back: UPDATE_ROLLBACK_COMPLETE
    ...

The main error is on the `JetsPreheatJob Embedded stack`.  You can check on this error in CloudFormation console and will find something like this:

![](/img/docs/debug/cloudformation-child-stack-error.png)

You can see here that the error is because the user does not have the necessary IAM permission. In this case, giving the user the [Minimal Deploy IAM Policy]({% link _docs/minimal-deploy-iam.md %}) will resolve the issue.

<a id="prev" class="btn btn-basic" href="{% link _docs/debugging-help.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/debugging-payloads.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
