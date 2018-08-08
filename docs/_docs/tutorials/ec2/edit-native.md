---
title: "Tutorial EC2: Edit Natively"
---

## Native CloudFormation Logical Constructs Approach

In the last section, we added conditional logical to create or not create an EIP using lono and generate different templates from the same source template. In this section, we'll use native CloudFormation constructs within one template. Hopefully, this gives you a helpful comparison between the 2 approaches.

Using native CloudFormation logical constructs is a little bit different but is just another valid approach. Sometimes it is preferable to compiling different templates; it just depends.  Here are the changes required to make the desired adjustments: [compare/eip-native](https://github.com/tongueroo/lono-tutorial-ec2/compare/eip-native).

The critical added element that drives the conditional logic is a parameter and 2 conditions.  The parameter is called `CreateEIP`, and the conditions are called `HasEIP` and `NoEIP`. Here's the relevant snippet of code:


```yaml
Parameters
...
  CreateEIP:
    Type: String
    Description: Determines whether or not to create an EIP address
Conditions:
  HasEIP: !Equals [ !Ref CreateEIP, "true" ]
  NoEIP: !Equals [ !Ref CreateEIP, "false" ]
```

The rest of the template uses these 2 new conditions to determine whether or not to create a Load Balancer.  For Properties, the use of the conditions look something like this:

```yaml
  IPAddress:
    Condition: HasEIP
    Type: AWS::EC2::EIP
  IPAssoc:
    Condition: HasEIP
    Type: AWS::EC2::EIPAssociation
    Properties:
      InstanceId:
        Ref: EC2Instance
      EIP:
        Ref: IPAddress
```

In this case, the changes are pretty simple with this approach.  For the sake of this guide, feel free to grab `app/templates/ec2.yml` from the [eip-native](https://github.com/tongueroo/lono-tutorial-ec2/blob/eip-native/app/templates/ec2.yml) branch and update the code to create the stacks.

### Launch Stack

After they have completed deletion, we're ready to relaunch both stacks:

```
lono cfn create ec2
lono cfn create eip --template ec2 --param eip
```

For the `eip` stack, we need to specify both `--template` and `--param` options since it breaks away from lono conventions.  Update the stack as much as you need to get things working:

```
lono cfn update ec2
lono cfn update eip --template ec2 --param eip
```

Once you're ready, remember to clean up and delete the stacks again.

```
lono cfn delete ec2
lono cfn delete eip
```

## Congrats

You have successfully created stacks, this time, using native CloudFormation constructs.

## Thoughts

We have successfully edited existing CloudFormation templates and taken 2 approaches to adding conditional logic:

1. Compiling Different Templates with Lono
2. Using Native CloudFormation Logical Constructs

A significant difference is when the conditional logic gets determined. When we use standard CloudFormation constructs, the logical decisions are made at **run-time**. When we use lono to produce multiple templates, it happens at **compile time**.  Whether this is good or bad is really up to how you use it. Remember, "With great power comes great responsibility."

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorials/ec2/edit-lono.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorials/ec2/cfn-delete.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
