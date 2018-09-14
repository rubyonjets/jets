---
title: Shared Resources
---

Shared resources are how you you create **standalone** custom AWS resources with Jets.  With the [Core Resource Model](http://rubyonjets.com/docs/core-resource/), you can customize and add any AWS resource and correspond them to Lambda functions.  Shared resources are also fully customizable AWS resources, but they are not as tightly associated with a Lambda function. Instead they are custom standalone resources. Understanding Shared Resources will allow you to customize a Jets application with any custom resource.

## SNS Topic Example

Let's create an SNS Topic as a shared resource. The SNS topic can be used throughout the application whenever we want to publish a message.


Shared resources are defined in the `app/shared/resources` folder.  You can created the sns topic like so:

app/shared/resources/alert.rb:

```ruby
class Alert < Jets::Stack
  sns_topic(:delivery_completed, display_name: "cool topic")
end
```

This results in an SNS Topic resource being created before Lambda functions from application classes like controllers or jobs are created.  You can then reference the SNS Topic with the `Alert.output` method:


```ruby
class PostmanJob < ApplicationJob
  include Jets::AwsServices

  def deliver
    topic_arn = Alert.lookup(:delivery_completed) # looks up output from the Alert cfn stack
    sns.publish(
      topic_arn: topic_arn,
      subject: "my subject",
      message: "my message"
    )
  end
end
```

Note, the code above uses `include Jets::AwsServices` to provide access to the `sns` client.  Refer to the source for a full list of the clients that are included with the module: [jets/aws_services.rb](https://github.com/tongueroo/jets/blob/master/lib/jets/aws_services.rb).

**Important:** You must use singularize names for your shared resource classes. So use `shared/resource.rb` instead of `shared/resources.rb`. Jets relies on this naming convention to handle autoloading shared resources. You can override this behavior by customizing inflections though with the [Application Configuration](http://rubyonjets.com/docs/app-config/).

## General Resource Form

In the SNS Topic example above we use the `sns_topic` convenience method to create the resource. Under the hood, the `sns_topic` method simply performs some wrapper logic and then calls the generalized `resource` and `output` method.  The code above could had been written like so:

```ruby
class Resource < Jets::Stack
  resource(
    "DeliveryCompleted": {
      type: "AWS::SNS::Topic",
      properties: {
        display_name: "cool topic"
      }
    }
  )
  output("DeliveryCompleted")
end
```

Understanding the general `resource` method is the key to adding any shared custom resource you require to a Jets application, so hopefully the explanation above helps.

## IAM Permission

The shared `Alert.output` lookup method requires read permission to the CloudFormation stack. This is automatically added to your application default IAM permissions when you are using Shared Resources and not have overriden the application wide IAM policy.

<a id="prev" class="btn btn-basic" href="{% link _docs/core-resource.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/database-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
