---
title: Shared Resources Depends On
---

CloudFormation has a concept of the [DependsOn Attribute](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-dependson.html). Normally, you do not have to use it as CloudFormation is smart enough to figure out how to sequence the creation of the dependent resources most of the time. For example, if you are creating a Route53 Record that's connects to ELB, CloudFormation knows to create the ELB before proceeding to create the Route53 record. There are times though when you need to specify the DependsOn attribute to control the creation order explicitly.

Jets creates most of the resources for you via [Nested CloudFormation stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html).  Shared Resources themselves are nested stacks. Sometimes you want to create resources in different nested stacks and one of them dependent on the other. In this case, the DependsOn attribute is required.

The `Jets::Stack` DSL makes this simple with the `depends_on` declaration. In addition to setting up the DependsOn attribute between the nested stacks appropriately, Jets also passes the [Outputs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) of the independent stack to the dependent stack so that it has access to the resources.  An example helps explain this:

app/shared/resources/alert.rb:

```ruby
class Alert < Jets::Stack
  sns_topic(:billing_alert)
end
```

app/shared/resources/alarm.rb:

```ruby
class Alarm < Jets::Stack
  depends_on :alert

  cloudwatch_alarm(:billing_alarm,
    alarm_description: "Alarm if AWS spending is too much",
    namespace: "AWS/Billing",
    metric_name: "EstimatedCharges",
    dimensions: [{name: "Currency", value: "USD"}],
    statistic: "Maximum",
    period: "21600", # every 6 hours
    evaluation_periods: "1",
    threshold: "100",
    comparison_operator: "GreaterThanThreshold",
    alarm_actions: [ref(:billing_alert)],
end
```

By declaring `depends_on :alert` in the `Alarm` class, Jets creates the `Alert` stack first and then creates the `Alarm` stack afterwards.  Jets also passes all the outputs from the `Alert` stack to the `Alarm` stack as [Parameters](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html). This allows the `Alarm` class to reference the BillingAlert SNS topic with `ref(:billing_alert)` even though it was created in another stack.

With this design, Jets makes it is easy to create many nested stacks and use resources from each other.

<a id="prev" class="btn btn-basic" href="{% link _docs/shared-resources-extensions.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/shared-resources-functions.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
