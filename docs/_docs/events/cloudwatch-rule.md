---
title: CloudWatch Rule Events
categories: events
---

Jets supports [CloudWatch Event Rules](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/Create-CloudWatch-Events-Rule.html). This allows you to have a Lambda function run when there's a change to AWS resources.  Here's an extensive list of supported [Event Types](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/EventTypes.html).

<div class="video-box"><div class="video-container"><iframe src="https://www.youtube.com/embed/0B2MqfZH-NE" frameborder="0" allowfullscreen=""></iframe></div></div>

## Example

An example might be getting notified when an unwanted security group port gets opened.

```ruby
class SecurityJob < ApplicationJob
  rule_event(
    description: "Checks for security group changes",
    detail_type: ["AWS API Call via CloudTrail"],
    detail: {
      event_source: ["ec2.amazonaws.com"],
      event_name: [
        "AuthorizeSecurityGroupIngress",
        "AuthorizeSecurityGroupEgress",
        "RevokeSecurityGroupIngress",
        "RevokeSecurityGroupEgress",
        "CreateSecurityGroup",
        "DeleteSecurityGroup"
      ]
    }
  )
  def detect_security_group_changes
    puts "event: #{JSON.dump(event)}" # event is available
    # your logic
  end
end
```

The `rule_event` declaration creates an [AWS::Events::Rule
](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html) and sets the `event_pattern` attributes.  The `description` property is treated specially and is added as a property to the AWS::Events::Rule structure appropriately.

Note, events for security group changes come from CloudTrail and currently take about 15 minutes to be delivered. Here's what the event rule looks like in the CloudWatch console:

![](/img/docs/cloudwatch-event-rule.png)

Here's an example from the CloudWatch log when the Lambda function runs:

![](/img/docs/cloudwatch-event-rule-log.png)

## Complete Form

If you need more control, and you can also set any properties of the [AWS::Events::Rule
](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html) by passing a hash. Here's another example that detects when an instance goes into stopping state.

```ruby
class SecurityJob < ApplicationJob
  rule_event(
    description: "Detects when instance stops",
    event_pattern: {
      source: ["aws.ec2"],
      detail_type: ["EC2 Instance State-change Notification"],
      detail: {
        state: ["stopping"],
      }
    }
  )
  def instance_stopping
    puts "event #{JSON.dump(event)}" # event is available
    # logic goes here
  end
end
```

This pattern of watching CloudWatch events can be used for things like automatically closing security group ports that get unintentionally opened. CloudWatch Events opens up a world of possibilities.

## Multiple Events Support

Registering multiple events to the same Lambda function is supported. Add multiple `rule_event` declarations above the method definition. Example:

```ruby
class SecurityJob < ApplicationJob
  rule_event(
    source: ["aws.ec2"],
    detail_type: ["EC2 Instance State-change Notification"],
    detail: {
      state: ["stopping"],
    }
  )
  rule_event(
    detail_type: ["AWS API Call via CloudTrail"],
    detail: {
      userIdentity: {
        type: ["Root"]
      }
    }
  )
  rate "10 hours"
  def perform_some_logic
    puts "event: #{JSON.dump(event)}" # event is available
    # logic goes here
  end
end
```

Notice in the above example that you can even mix in the `rate` declaration with the Lambda function.  Underneath the hood `rate` delegates to the `rule_event` method.

## Related links

* [Invoke Lambda Function in Response to an Event](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html#w2ab1c21c10d697c13b4)
* [Event Patterns in CloudWatch Events](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html)
* [CloudWatch Events Event Examples From Each Supported Service](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/EventTypes.html) - Long list of supported events.

