---
title: Core Resource Model
---

At the core of Jets is the resource model. Understanding the core `resource` model and method will allow you to create any resource via CloudFormation with Jets.

## All Paths Lead to resource

An important learning point is that all resources associated with each Lambda function in Jets are ultimately created by the `resource` method. The `resource` method is the key.

For example, the `rate` method creates a CloudWatch Event Rule resource. This Event Rule resource is associated with the `dig` Lambda function. Here's an example:

```ruby
class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    {done: "digging"}
  end
end
```

What's happens is that Jets takes the `rate` method, performs some wrapper logic, and calls the core `resource` method.  In other words, the code could also be written like so:

```ruby
class HardJob < ApplicationJob
  resource(
    "{namespace}EventsRule": {
      type: "AWS::Events::Rule",
      properties: {
        schedule_expression: "rate(10 hours)",
        state: "ENABLED",
        targets: [{
          arn: "!GetAtt {namespace}LambdaFunction.Arn",
          id: "{namespace}RuleTarget"
        }]
      }
    }
  )
  def dig
    {done: "digging"}
  end
end
```

Jets replaces the `{namespace}` with an identifier a value that has the class and method that represents the Lambda function. For example:

Before | After
--- | ---
{namespace} | HardJobDig

The final code looks something like this:

```ruby
class HardJob < ApplicationJob
  resource(
    "HardJobDigEventsRule": {
      type: "AWS::Events::Rule",
      properties: {
        schedule_expression: "rate(10 hours)",
        state: "ENABLED",
        targets: [{
          arn: "!GetAtt HardJobDigLambdaFunction.Arn",
          id: "HardJobDigRuleTarget"
        }]
      }
    }
  )
  def dig
    {done: "digging"}
  end
end
```

The `resource` method creates the [AWS::Events::Rule](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html) as a CloudFormation resource. The keys of the Hash structure use the underscore format following Ruby naming convention. As part of CloudFormation template processing, the underscored keys are camelized before deploying to CloudFormation.

With this design, Jets allows you to create any resource associated with your Lambda functions. Once you see how the `resource` method works, you can define any resource that you required. Methods like `rate`, `cron`, `event_rule`, `event_pattern` simply run some setup logic and call the `resource` method.

Understanding the core `resource` model is key to unlocking the power of full customization to a Jets application. Once you get used to the `resource` method, you would start defining your own custom shorthand resource methods that wrap the `resource` method for more concise code.

<a id="prev" class="btn btn-basic" href="{% link _docs/faster-development.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/shared-resources.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
