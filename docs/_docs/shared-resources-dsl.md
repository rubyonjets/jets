---
title: Shared Resources DSL
---

As mentioned in [Shared Resources]({% link _docs/shared-resources.md %}), the `sns_topic` is simply a convenience method that calls `resources` and `output`. Shared Resources inherit from the `Jets::Stack` class.  The `Jets::Stack` class provides a DSL that generally can be used to be a CloudFormation template.  Here are the methods that cover the the [CloudFormation anatomy sections](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html) that are useful for Jets.

DSL Method | Description
--- | ---
parameter | Adds a parameter to the template.
resource |Adds a resource to the template.
output |Adds a output to the template.

Each method has long, medium and short forms.  Here's an contrived example that shows the different forms with the different methods:

```ruby
class ContrivedExample < Jets::Stack
  ### Parameters
  # long form
  parameter(instance_type: {
    default: "t2.micro" ,
    description: "instance type" ,
  })
  # medium form
  parameter :company, default: "boltops"
  # short form
  parameter :ami_id, "ami-123"

  ### Outputs
  # long form
  output(vpc_id: {
    description: "vpc id",
    value: ref("vpc_id"),
  })
  # medium form
  output :stack_name, value: "!Ref AWS::StackName"
  # short form
  output :elb, "!Ref Elb"
  output :elb2 # short form

  ### Resources
  # long form
  resource(sns_topic: {
    type: "AWS::SNS::Topic",
    properties: {
      description: "my desc",
      display_name: "my name",
    }
  })
  # medium form
  resource(:sns_topic2,
    type: "AWS::SNS::Topic",
    properties: {
      display_name: "my name 2",
    }
  )
  # short form
  resource(:sns_topic3, "AWS::SNS::Topic",
    display_name: "my name 3",
  )
end
```

The DSL provides plentiful access to creating custom CloudFormation stacks and AWS resources.  It is also easy extend the DSL with your own [Shared Resource Extensions]({% link _docs/shared-resources-extensions.md %}). This helps you remove duplication and keep your code concise.

<a id="prev" class="btn btn-basic" href="{% link _docs/shared-resources.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/shared-resources-extensions.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
