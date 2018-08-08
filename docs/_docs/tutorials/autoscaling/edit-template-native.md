---
title: "Tutorial: Edit Template Native"
---

## Native CloudFormation Logical Constructs Approach

In the last section, we added conditional logical to create or not create a Load Balancer using lono variables. In this section, we'll use native CloudFormation constructs.  This hopefully gives you a sense of the differences in the 2 approaches.

Using native CloudFormation logical constructs is a little bit different but just as valid of an approach. Sometimes it is preferable to compiling different templates; it just depends.  Here are the changes required to make the desired adjustments: [compare/native-constructs](https://github.com/tongueroo/lono-tutorial-autoscaling/compare/native-constructs).  Note, UserData and the UpdatePolicy were to removed for the sake of this guide and to focus on learning.

The critical added element that drives the conditional logic is a parameter and 2 conditions.  The parameter is called `CreateLoadBalancer` and the conditions are called `HasLoadBalancer` and `NoLoadBalancer`. Here's the relevant snippet of code:


```yaml
Parameters
...
  CreateLoadBalancer:
    Type: String
    Description: 'Determines if a Load Balancer is created. Example: true or false'
Conditions:
  HasLoadBalancer: !Equals [ !Ref CreateLoadBalancer, "true" ]
  NoLoadBalancer: !Equals [ !Ref CreateLoadBalancer, "false" ]
```

The rest of the template uses these 2 new conditions to determine whether or not to create a Load Balancer.  For Properties, the use of the conditions look something like this:

Before:

```yaml
     Properties:
       SecurityGroups:
      - Ref: InstanceSecurityGroup
```

After:

```yaml
     Properties:
       SecurityGroups:
      - !If [HasLoadBalancer, !Ref WebInstanceSecurityGroup, !Ref WorkerInstanceSecurityGroup]
```

For template resources, we usually have to define 2 resources and then toggle between them with the conditions like so:

Before:

```yaml
  InstanceSecurityGroup:
    Type: AWS::EC2::SecurityGroup
```

After:

```yaml
  WebInstanceSecurityGroup:
    Condition: HasLoadBalancer
    Type: AWS::EC2::SecurityGroup
    ...
  WorkerInstanceSecurityGroup:
    Condition: NoLoadBalancer
    Type: AWS::EC2::SecurityGroup
    ...
```

For the sake of this guide, feel free to grab `app/templates/autoscaling` from the [native-constructs](https://github.com/tongueroo/lono-tutorial-autoscaling/blob/native-constructs/app/templates/autoscaling.yml) branch and update the code.

### Launch Stack

After they have completed deletion, we're ready to relaunch both stacks:

```
lono cfn create autoscaling-web --template autoscaling --param autoscaling-web
lono cfn create autoscaling-worker --template autoscaling --param autoscaling-worker
```

In this case, we need to specify both `--template` and `--param` options since it breaks away from lono conventions.  We have successfully relaunched stacks!  This time with native CloudFormation constructs.  Remember to clean up and delete the stacks again.

```
lono cfn delete autoscaling-web
lono cfn delete autoscaling-worker
```

## Thoughts

We have successfully edited existing CloudFormation templates and taken 2 approaches to adding conditional logic:

1. Compiling Different Templates with Lono
2. Using Native CloudFormation Logical Constructs

A major difference is when the conditional logic gets determined. When we use standard CloudFormation constructs, the logical decisions get made at **run-time**. When we use lono to produce multiple templates it happens at **compile time**.  Whether this is good or bad is really up to how you use it. Remember, "With great power comes great responsibility."
