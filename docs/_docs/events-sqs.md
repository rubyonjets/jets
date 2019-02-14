---
title: SQS Events
---

Jets supports [SQS Events](https://aws.amazon.com/blogs/aws/aws-lambda-adds-amazon-simple-queue-service-to-supported-event-sources/) as a Lambda trigger. So you can send a message to an SQS queue and it triggers a Lambda function to run.  The Lambda function has access to the message data via `event`. There are a few ways to connect an SQS queue to a Lambda function with Jets.

1. Existing SQS Queue
2. Generated Function SQS Queue
3. Generated Shared SQS Queue

We'll cover each of them:

## Existing SQS Queue

Here is an example connecting an existing SQS queue to the Lambda function in a [Job]({% link _docs/jobs.md %})

```ruby
class HardJob
  class_timeout 30 # must be less than or equal to the SQS queue default timeout
  sqs_event "hello-queue"
  def dig
    puts "dig event #{JSON.dump(event)}"
  end
end
```

Ultimately, the `sqs_event` declaration generates a [Lambda::EventSourceMapping](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventsourcemapping.html).  The properties of the mapping can be set with an additional Hash argument:

```ruby
  sqs_event("hello-queue", batch_size: 10)
```

## Generated Function SQS Queue

Jets can create and manage an SQS queue for a specific function. This is done with a special `:generate_queue` argument.

```ruby
class HardJob
  class_timeout 30 # must be less than or equal to the SQS queue default timeout
  sqs_event :generate_queue
  def lift
    puts "lift event #{JSON.dump(event)}"
  end
end
```

A special `:queue_properties` key will set the [SQS::Queue](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-sqs-queues.html) properties. Other keys set the [Lambda::EventSourceMapping](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventsourcemapping.html) properties.  Example:

```ruby
  sqs_event(:generate_queue,
    batch_size: 10, # property of EventSourceMapping
    queue_properties: {
      message_retention_period: 345600, # 4 days in seconds
  })
```

Note, SQS Queues managed by Jets are deleted when you delete the Jets application.

## Generated Shared SQS Queue

Jets can also support creating a shared SQS Queue via a [Shared Resource]({% link _docs/shared-resources.md %}). Here's how you create the SQS queue as a shared resource:

app/shared/resources/list.rb:

```ruby
class List < Jets::Stack
  sqs_queue(:waitlist)
end
```

You can reference the Shared Queue like so:

app/jobs/hard_job.rb:

```ruby
class HardJob
  class_timeout 30 # must be less than or equal to the SQS queue default timeout
  depends_on :list # makes Jets pass the List shared resource outputs to HardJob
  sqs_event "!Ref Waitlist" # reference Waitlist by camelized convention
  def fix
    puts "fix #{JSON.dump(event)}"
  end
end
```

Underneath the hood, Jets provisions resources via CloudFormation.  The use of `depends_on` ensures that Jets will pass the shared resource `List` stack outputs to the `HardJob` stack as input parameters. This allows `HardJob` to reference resources from the separate child `List` stack.

{% include cloudformation_links.md %}

## IAM Policy

An IAM policy is generated for the Lambda function associated with the SQS event that allows the permissions needed.  You can control and override the IAM policy with normal [IAM Policies]({% link _docs/iam-policies.md %}) if needed though.

## FIFO Queue

Note, AWS does not currently support Lambda function triggers with FIFO queues, so the queue must be a standard queue to use Lambda triggers.  If you are using a FIFO queue, a [possible way](https://stackoverflow.com/questions/53416890/cant-trigger-lambdas-on-sqs-fifo) to process the messages is with a Job that polls the queues and does the processing.

<a id="prev" class="btn btn-basic" href="{% link _docs/events-sns.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/database-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
