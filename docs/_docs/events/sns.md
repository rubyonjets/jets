---
title: SNS Events
categories: events
---

Jets supports [SNS Events](https://docs.aws.amazon.com/lambda/latest/dg/with-sns-example.html) as a Lambda trigger. So you can send a message to an SNS topic and it triggers a Lambda function to run.  The Lambda function has access to the message data via `event`.

<div class="video-box"><div class="video-container"><iframe src="https://www.youtube.com/embed/XT_7xaQVEzU" frameborder="0" allowfullscreen=""></iframe></div></div>


There are a few ways to connect an SNS topic to a Lambda function with Jets.

1. Existing SNS Topic
2. Generated Function SNS Topic
3. Generated Shared SNS Topic

We'll cover each of them:

## Existing SNS Topic

Here is an example connecting an existing SNS topic to a Lambda function in a [Job]({% link _docs/jobs.md %})

```ruby
class HardJob < ApplicationJob
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
class HardJob < ApplicationJob
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
  sns_topic(:engineering)
end
```

You can reference the Shared Topic like so:

app/jobs/hard_job.rb:

```ruby
class HardJob < ApplicationJob
  depends_on :topic # so we can reference topic shared resources
  sns_event ref(:engineering) # reference sns topic in shared resource
  def fix
    puts "fix #{JSON.dump(event)}"
  end
end
```

Underneath the hood, Jets provisions resources via CloudFormation.  The use of `depends_on` ensures that Jets will pass the shared resource `Topic` stack outputs to the `HardJob` stack as input parameters. This allows `HardJob` to reference resources from the separate child `Topic` stack.

{% include cloudformation_links.md %}

## Publish Test Message

Here's an example of publishing a test message to an SNS topic via the [aws sns publish](https://docs.aws.amazon.com/cli/latest/reference/sns/publish.html) CLI:

    aws sns publish --topic-arn arn:aws:sns:us-west-2:112233445566:my-topic --message '{"default": "test message"}'

You can send a message via the SNS Console, sdk, etc also.

## Event Payloads

```json
{
    "Records": [
        {
            "EventSource": "aws:sns",
            "EventVersion": "1.0",
            "EventSubscriptionArn": "arn:aws:sns:us-west-2:112233445566:demo-dev-Topic-JSTMFREHSV9U-Engineering-1PS3HM70TS67H:ba5887af-fe4c-44c9-bbd7-f7f0e6d652de",
            "Sns": {
                "Type": "Notification",
                "MessageId": "e3d54a5f-fee2-51cc-abc7-1eb99d074475",
                "TopicArn": "arn:aws:sns:us-west-2:112233445566:demo-dev-Topic-JSTMFREHSV9U-Engineering-1PS3HM70TS67H",
                "Subject": null,
                "Message": "{\"default\": \"test message\"}",
                "Timestamp": "2019-02-19T20:05:57.063Z",
                "SignatureVersion": "1",
                "Signature": "XDv0YTmNgyfqTLiWDev6ZRMkl9PoWnlAYIM5jW9PmPRrYG+TdfDAxcxmD7gYsEk3Eol/EqtBlFHTjWVcH7F6JQDu6hNO1P4f/k0VLGX94AdMP51riGDAC/S4yuHPT1Muq1WLFuT/Ttol1cTW2UH5kVMG7eIOfNTt4Qe3Kf4q2pRNTh5Z2EGULgjkea//OsRIfz3vfLlNUTyn1JKp2Q427CpoSZ/4YSk/wdL7IEVzWbKssgkiITIzLxS/KUr30OF+WLCnvHbBLVXo8nyscRTHRho6cgC4QtjUL6XOeXh5EPg4NB0i5nzgBe+2xIgXne5yMUHIWwW6fQ8Ouq+UliO4ZA==",
                "SigningCertUrl": "https://sns.us-west-2.amazonaws.com/SimpleNotificationService-ac565b8b1a6c5d002d285f9598aa1d9b.pem",
                "UnsubscribeUrl": "https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:112233445566:demo-dev-Topic-JSTMFREHSV9U-Engineering-1PS3HM70TS67H:ba5887af-fe4c-44c9-bbd7-f7f0e6d652de",
                "MessageAttributes": {}
            }
        }
    ]
}
```

