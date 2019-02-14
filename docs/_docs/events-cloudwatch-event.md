---
title: CloudWatch Events
---

Jets supports [CloudWatch Event Rules](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/Create-CloudWatch-Events-Rule.html). This allows you to have a Lambda function run when there's a change to AWS resources.  Here's an extensive list of supported [Event Types](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/EventTypes.html).

## Example

An example might be getting notified when an unwanted security group port gets opened.

```ruby
class SecurityJob < ApplicationJob
  events_rule(
    description: "Detects security group changes",
    event_pattern: {
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
    }
  )
  def detect_security_group_changes
    puts "event: #{JSON.dump(event)}" # event is available
    # your logic
  end
end
```

Here's what the event rule looks like in the CloudWatch console:

![](/img/docs/cloudwatch-event-rule.png)

Here's an example from the CloudWatch log when the Lambda function runs:

![](/img/docs/cloudwatch-event-rule-log.png)

## Simple Examples

You can further simplify the code with `event_pattern`. Here's another example that detects when an instance goes into stopping state.

```ruby
class SecurityJob < ApplicationJob
  event_pattern(
    source: ["aws.ec2"],
    detail_type: ["EC2 Instance State-change Notification"],
    detail: {
      state: ["stopping"],
    }
  )
  def instance_stopping
    # logic goes here
  end
end
```

This pattern of watching CloudWatch events can be used for things like automatically closing security group ports that get unintentionally opened. CloudWatch Events opens up a world of possibilities.

## Multiple Events Support

Registering multiple events to the same Lambda function is supported. Add multiple event rules above the method definition. Example:

```ruby
class SecurityJob < ApplicationJob
  event_pattern(
    source: ["aws.ec2"],
    detail_type: ["EC2 Instance State-change Notification"],
    detail: {
      state: ["stopping"],
    }
  )
  event_pattern(
    detail_type: ["AWS API Call via CloudTrail"],
    detail: {
      userIdentity: {
        type: ["Root"]
      }
    }
  )
  rate "10 hours"
  def perform_some_logic
    # logic goes here
  end
end
```

Notice in the above example that you can even mix in the `rate` declaration with the Lambda function.  Underneath the hood `rate` delegates to the `events_rule` method.

## Related links

* [Invoke Lambda Function in Response to an Event](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html#w2ab1c21c10d697c13b4)
* [Event Patterns in CloudWatch Events](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html)
* [CloudWatch Events Event Examples From Each Supported Service](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/EventTypes.html) - Long list of supported events.


<a id="prev" class="btn btn-basic" href="{% link _docs/events.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/events-cloudwatch-log.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
