---
title: SNS Events
categories: events
---

Jets supports [SNS Events](https://docs.aws.amazon.com/lambda/latest/dg/with-sns-example.html) as a Lambda trigger. So you can send a message to an SNS topic and it triggers a Lambda function to run.  The Lambda function has access to the message data via `event`. There are a few ways to connect an SNS topic to a Lambda function with Jets.

1. Existing SNS Topic
2. Generated Function SNS Topic
3. Generated Shared SNS Topic

We'll cover each of them:

## Existing SNS Topic

Here is an example connecting an existing SNS topic to a Lambda function in a [Job]({% link _docs/jobs.md %})

```ruby
class HardJob
  class_timeout 30 # must be less than or equal to the SNS Topic default timeout
  sns_event "hello-topic"
  def dig
    puts "dig event #{JSON.dump(event)}"
  end
end
```

Ultimately, the `sns_event` declaration generates a [SNS::Subscription](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-sns-subscription.html).  The properties of the subscription can be set with an additional Hash argument:

```ruby
  sns_event("hello-topic", filter_policy: {store: "example_corp"})
```

There's more information on the filter_policy here on [SNS Message Filtering](https://docs.aws.amazon.com/sns/latest/dg/sns-message-filtering.html).

## Generated Function SNS Topic

Jets can create and manage an SNS Topic for a specific function. This is done with a special `:generate_topic` argument.

```ruby
class HardJob
  class_timeout 30 # must be less than or equal to the SNS Topic default timeout
  sns_event :generate_topic
  def lift
    puts "lift event #{JSON.dump(event)}"
  end
end
```

A special `:topic_properties` key will set the [SNS::Topic](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-sns-topic.html) properties. Other keys set the [SNS::Subscription](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-sns-subscription.html) properties.  Example:


```ruby
  sns_event(:generate_topic,
    batch_size: 10,
    topic_properties: {display_name: "My awesome topic"}
  )
```

Here's an example screenshot of a generated SNS topic:

![](/img/docs/sns-topic.png)

Note, SNS Topics managed by Jets are deleted when you delete the Jets application.

## Generated Shared SNS Topic

Jets can also support creating a shared SNS Topic via a [Shared Resource]({% link _docs/shared-resources.md %}). Here's how you create the SNS Topic as a shared resource:

app/shared/resources/topic.rb:

```ruby
class Topic < Jets::Stack
  sqs_queue(:engineering)
end
```

You can reference the Shared Topic like so:

app/jobs/hard_job.rb:

```ruby
class HardJob
  depends_on :topic # makes Jets pass the Topic shared resource outputs to HardJob
  sns_event "!Ref Engineering" # reference Engineering by camelized convention
  def fix
    puts "fix #{JSON.dump(event)}"
  end
end
```

Underneath the hood, Jets provisions resources via CloudFormation.  The use of `depends_on` ensures that Jets will pass the shared resource `Topic` stack outputs to the `HardJob` stack as input parameters. This allows `HardJob` to reference resources from the separate child `Topic` stack.

{% include cloudformation_links.md %}

<a id="prev" class="btn btn-basic" href="{% link _docs/events-s3.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/events-sqs.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
