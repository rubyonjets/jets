---
title: Shared Resources
---

Shared resources are how you create **standalone** custom AWS resources with Jets.  With the [Associated Resources]({% link _docs/function-resources.md %}), you can add custom AWS resources which are associated with Lambda functions.  Shared resources are also fully customizable AWS resources, but they are not as tightly associated with a Lambda function. Understanding Shared Resources will allow you to customize a Jets application with any custom resource.

## SNS Topic Example

Let's create an SNS Topic as a shared resource. The SNS topic will be used throughout the application to publish messages.

Shared resources are defined in the `app/shared/resources` folder.  You can create the SNS topic like so:

app/shared/resources/alert.rb:

```ruby
class Alert < Jets::Stack
  sns_topic(:delivery_completed, display_name: "cool topic")
end
```

This creates an SNS Topic resource.  You can then reference the SNS Topic with the `Alert.lookup` method in your code. For example, here's a [Job]({% link _docs/jobs.md %}) that looks up the ARN of the `delivery_completed` SNS topic and then publishes to it.

```ruby
class PostmanJob < ApplicationJob
  include Jets::AwsServices

  iam_policy("sns")
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

The `lookup` method is available to the `Alert` class as a part of inheriting from the `Jets::Stack` class. Also note, the code above uses `include Jets::AwsServices` to provide access to the `sns` client.  Refer to the source for a full list of the clients that are included with the module: [jets/aws_services.rb](https://github.com/boltops-tools/jets/blob/master/lib/jets/aws_services.rb). For services not included, add the gem to your project's Gemfile and set up the client in the code.

## General Resource Form

In the SNS Topic example above we use the `sns_topic` convenience method to create the resource. Under the hood, the `sns_topic` method simply performs some wrapper logic and then calls the generalized `resource` and `output` method.  The code above could have been written like so:

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
  output("DeliveryCompleted") # creates CloudFormation output
end
```

The Jets::Stack `resource` method is similar to [Custom Associated Resources's]({% link _docs/function-resources.md %}) `resource` method. It follows a similar expansion pattern.  With it, you can create any AWS resource in your Jets application. You can also create your own convenience wrapper methods and call `resource` and `output` as required: [Shared Resource Extensions]({% link _docs/shared-resources/extensions.md %}).

## IAM Permission

The Jets::Stack `lookup` method uses a [CloudFormation Output](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) that is created as part of the convenience methods.  The `lookup` method requires read permission to the CloudFormation stack. This permission is automatically added to your application default IAM permissions when you are using Shared Resources, given you have not have overridden the [application-wide IAM policy]({% link _docs/iam-policies.md %}).

Understanding the general shared `resource` method is the key to adding any shared custom resource you require to a Jets application, so hopefully the explanations above help.

