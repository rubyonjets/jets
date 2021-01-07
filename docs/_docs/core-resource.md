---
title: Core Resource Model
---

At the core of Jets is the resource model. Understanding the core `resource` model and method will allow you to create any resource supported by CloudFormation with Jets.

## All Paths Lead to resource

An important learning point is that all resources associated with each Lambda function in Jets are ultimately created by the `resource` method. The `resource` method is the key.

For example, the `rate` method creates a CloudWatch Event Rule resource. This Event Rule resource is associated with the `dig` Lambda function. Here's an example:

```ruby
class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    puts "done digging"
  end
end
```

What's happens is that Jets takes the `rate` method, performs some wrapper logic, and calls the core `resource` method.  In other words, the code could also be written like so:

```ruby
class HardJob < ApplicationJob
  resource(
    "DigEventsRule": {
      type: "AWS::Events::Rule",
      properties: {
        schedule_expression: "rate(10 hours)",
        state: "ENABLED",
        targets: [{
          arn: "!GetAtt DigLambdaFunction.Arn",
          id: "DigRuleTarget"
        }]
      }
    }
  )
  def dig
    puts "done digging"
  end
end
```

The `resource` method creates the [AWS::Events::Rule](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html) as a CloudFormation resource.

With this design, you can create any resource with Jets and associate them with your Lambda functions. Once you understand how the `resource` method works, you can define any resource that you required. Methods like `rate`, `cron`, `rule_event` simply run some setup logic and call the `resource` method.

