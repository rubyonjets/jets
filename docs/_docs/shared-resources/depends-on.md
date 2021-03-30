---
title: Shared Resources Depends On
---

CloudFormation has a concept of the [DependsOn Attribute](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-dependson.html). Normally, you do not have to use it as CloudFormation is smart enough to figure out how to sequence the creation of the dependent resources most of the time. For example, if you are creating a Route53 Record that's connected to ELB, CloudFormation knows to create the ELB before proceeding to create the Route53 record. There are times though when you need to specify the DependsOn attribute to control the creation order explicitly.

Jets creates most of the resources for you via [Nested CloudFormation stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html).  Shared Resources themselves are nested stacks. Sometimes you want to create resources in different nested stacks and one of them dependent on the other. This is a case where the DependsOn attribute is required.

The `Jets::Stack` DSL makes managing dependencies between nested stacks simple with the `depends_on` declaration. In addition to setting up the DependsOn attribute between the nested stacks appropriately, Jets also passes the [Outputs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) of the independent stack to the dependent stack so that it has access to the resources.  An example helps explain this.

## DependsOn Example

Let's say we wanted to create a CloudWatch Alarm and an SNS Alert and organized them in different classes. The CloudWatch Alarm depends on the SNS Alert. So the SNS Alert needs to be created before the Alarm.  Here's how we achieve this with the `depends_on` declaration.

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
  )
end
```

By declaring `depends_on :alert` in the `Alarm` class, Jets creates the `Alert` stack first and then creates the `Alarm` stack afterwards.  Jets also passes all the outputs from the `Alert` stack to the `Alarm` stack as [Parameters](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html). This allows the `Alarm` class to reference the BillingAlert SNS topic with `ref(:billing_alert)` even though it was created in another stack.

With this design, Jets makes it is easy to create many nested stacks and use resources from each other.

## App Classes: Controllers, Jobs, Etc

The `depends_on` declaration also works in non-shared app classes.  When you add `depends_on` to an app class like a controller or a job, Jets will ensure that the resources are created in the dependent order and also pass the outputs of the independent stack to the dependent stack. This is useful in case you want to reference a resource from one stack to another.  Example:

app/shared/resources/list.rb:

```ruby
class List < Jets::Stack
  sqs_queue(:waitlist)
end
```

app/jobs/hard_job.rb:

```ruby
class HardJob < ApplicationJob
  depends_on :list
  class_timeout 30 # less than to equal to the default queue timeout

  sqs_queue "!Ref Waitlist"
  def dig
    puts "done digging"
  end
end
```

Understanding of what is happening underneath the hood with Jets and CloudFormation helps to understand shared resources usage. Remember that each class gets translated into a nested child stack. The parameters are possibly passed between the stacks. The depends_on declaration tells Jets to pass all the outputs from the `List` stack as input parameters to the `HardJob` stack.  In this case, one of the outputs from the `sqs_queue(:waitlist)` resource declaration is `Waitlist`. The `Waitlist` output contains the SQS arn.  `HardJob` references the input parameter. This is how it is possible for `HardJob` to refer to a resource created in another stack.

