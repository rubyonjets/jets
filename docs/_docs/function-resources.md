---
title: Associated Resources
---

As explained in the [Core Resource Model](http://rubyonjets.com/docs/core-resource/) docs, methods like `rate` and `cron` simply perform some wrapper logic and then ultimately call the `resource` method. We'll cover that wrapper logic and expansion process in more details here.

The `rate` method creates a CloudWatch Event Rule resource. This Event Rule resource is associated with the `dig` Lambda function. Here's the example again:

```ruby
class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    puts "done digging"
  end
end
```

What happens is that Jets takes the `rate` method, performs some wrapper logic, and calls the core `resource` method in the first pass.  The code looks something like this after the first pass:

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
    puts "done digging"
  end
end
```

In the second pass, Jets replaces the `{namespace}` with an identifier a value that has method name that represents the Lambda function. For example:

Before | After
--- | ---
{namespace} | Dig

The final code looks something like this:

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

The `resource` method creates the [AWS::Events::Rule](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html) as a CloudFormation resource. The keys of the Hash structure use the underscore format following Ruby naming convention. As part of CloudFormation template processing, the underscored keys are camelized.

Understanding the core `resource` model is key to unlocking the power of full customization to a Jets application. Once you get used to the `resource` method, you could start defining your own custom convenience resource methods that wrap the `resource` method for more concise code as [Associated Resources Extensions]({% link _docs/function-resources/function-resources-extensions.md %}).

