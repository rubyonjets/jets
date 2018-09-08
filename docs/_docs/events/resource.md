---
title: Core Resource Modeling
---

This explains how the core resource modeling works with Jets. Understanding the core `resource` method will allow you to create any resource supported by CloudFormation with Jets.

## All Paths Lead to resource

An important learning point is that all resources associated with each Lambda function in Jets are ultimately created by the `resource` method. The `resource` method is the key.

For example, the `rate` method creates a CloudWatch Event Rule resource. This Event Rule is associated with the `dig` Lambda function. Here's an example:

```ruby
class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    {done: "digging"}
  end
end
```

What's actually happening is that Jets takes the `rate` method and calls the core `resource` method.  So the code could also be written like so:

```ruby
class HardJob < ApplicationJob
  resource(
    "{namespace}EventsRule": {
      type: "AWS::Events::Rule",
      properties: {
        schedule_expression: "rate(10 hours)"
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

Jets will replace the `{namespace}` with an identifier that has the class and method. For example:

Before | After
--- | ---
{namespace} | HardJobDig

The final code will look like this:

```ruby
class HardJob < ApplicationJob
  resource(
    "HardJobDigEventsRule": {
      type: "AWS::Events::Rule",
      properties: {
        schedule_expression: "rate(10 hours)"
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

The `resource` method creates the [AWS::Events::Rule](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html) as a CloudFormation resource. The keys of the Hash structure use the underscore format because that's Ruby convention. As part of the CloudFormation processing, the keys are camelized and then deployed to CloudFormation.

Jets, by design, allows you to create any resource and associated them with your Lambda functions. Methods like `rate`, `event_rule`, `event_pattern` simply provide some wrapping setup logic and call the `resource` method.

<a id="prev" class="btn btn-basic" href="{% link _docs/polymorphic-node.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorials.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
