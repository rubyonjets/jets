---
title: Shared Resources DSL
---

As mentioned in [Shared Resources]({% link _docs/shared-resources.md %}), the `sns_topic` is simply a convenience method that calls the `resources` and `output` methods that add sections to the CloudFormation template. Shared Resources inherit from the `Jets::Stack` class.  By inheriting from the `Jets::Stack` class, Shared Resources are provided access to a general CloudFormation template DSL.  Here are the main methods of that DSL:

DSL Method | Description
--- | ---
parameter | Adds a parameter to the template.
resource | Adds a resource to the template.
output | Adds an output to the template.

The main methods correspond to sections of the [CloudFormation anatomy sections](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html).

Each method has long, medium and short forms.  Here are some contrived examples that show their different forms:

## Parameters

```ruby
class ParametersExample < Jets::Stack
  # long form
  parameter(instance_type: {
    default: "t2.micro" ,
    description: "instance type" ,
  })
  # medium form
  parameter :company, default: "boltops", description: "instance type"
  # short form
  parameter :ami_id, "ami-123" # default is ami-123
end
```

## Resources

```ruby
class ResourcesExample < Jets::Stack
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

## Outputs

```ruby
class OutputsExample < Jets::Stack
  # long form
  output(vpc_id: {
    description: "vpc id",
    value: ref("vpc_id"), # same as: value: "!Ref VpcId"
  })
  # medium form
  output :stack_name, value: "!Ref AWS::StackName"
  # short form
  output :elb, "!Ref Elb" # same as
               # output :elb, value: "!Ref Elb"
  output :elb2 # short form, same as:
               # output :elb2, "!Ref Elb2"

end
```

The DSL provides full access to creating custom CloudFormation stacks and AWS resources.  It is also easy extend the DSL with your own [Shared Resource Extensions]({% link _docs/shared-resources/extensions.md %}). This helps you remove duplication and keep your code concise.

