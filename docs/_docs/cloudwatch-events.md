---
title: CloudWatch Events
---

AWS Lambda supports on [CloudWatch Event Rules](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/Create-CloudWatch-Events-Rule.html). This ability allows you to have a Lambda function run when there's a change to your AWS resources.  Here's a long list of supported [Event Types](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/EventTypes.html).

An example might be getting notified whenever an unwanted security group port gets opened up.

```ruby
class SecurityJob < ApplicationJob
  event_rule(
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
    puts event # event is available
    # your logic
  end
end
```

You can further simplify the code `event_pattern`. Here's another example that detects when an instance goes into stopping.

```ruby
class SecurityJob < ApplicationJob
  event_pattern(
    source: ["aws.ec2"],
    detail_type: ["EC2 Instance State-change Notification"],
    detail: {
      state: ["stopping"],
    }
    def instance_stopping
      # logic goes here
    end
  )
end
```

This pattern of watching CloudWatch events be used for automating things like automatically closing back up security group ports that get unintentionally get opened. CloudWatch Events opens up a world of possible uses.

## Related links

* [Invoke Lambda Function in Response to an Event](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html#w2ab1c21c10d697c13b4)
* [Event Patterns in CloudWatch Events](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html)
* [CloudWatch Events Event Examples From Each Supported Service](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/EventTypes.html) - Long list of supported events.


<a id="prev" class="btn btn-basic" href="{% link _docs/polymorphic-node.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorials.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
