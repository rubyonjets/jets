---
title: "Tutorial: Launch the Stack"
---

## Launch the Stack

We're now ready to launch the stack!  Use the `lono cfn create autoscaling` command:

```
$ lono cfn create autoscaling
Using template: output/templates/autoscaling.yml
Using parameters: config/params/development/autoscaling.txt
No detected app/scripts
Generating CloudFormation templates:
  output/templates/autoscaling.yml
  output/params/autoscaling.json
Parameters passed to cfn.create_stack:
---
stack_name: autoscaling
template_body: 'Hidden due to size... View at: output/templates/autoscaling.yml'
parameters:
- parameter_key: VpcId
  parameter_value: vpc-d79753ae
- parameter_key: Subnets
  parameter_value: subnet-4ac50f66,subnet-622eee38,subnet-83cf49cb,subnet-29e75925,subnet-f45d02c8,subnet-3fb1875a
- parameter_key: OperatorEMail
  parameter_value: email@domain.com
- parameter_key: KeyName
  parameter_value: default
capabilities:
disable_rollback: false
Creating autoscaling stack.
$
```

The `lono cfn create` command did a few things:

1. Generates the imported templates to the `output/templates` folder.
2. Generates the generated params files to the `output/params` folder.
3. Launches the CloudFormation stack with the values from the `output` folder.

You should see a CloudFormation stack creating:

<img src="/img/tutorial/lono-cfn-create-autoscaling.png" alt="Stack Created" class="doc-photo lono-flowchart">

## Check the Created Resources

You can use `lono summary autoscaling` to get a summary of the Resources again.

```
$ lono summary autoscaling
=> CloudFormation Template Summary:
Parameters:
Required:
  VpcId (AWS::EC2::VPC::Id)
  Subnets (List<AWS::EC2::Subnet::Id>)
  OperatorEMail (String)
  KeyName (AWS::EC2::KeyPair::KeyName)
Optional:
  InstanceType (String) Default: t2.small
  SSHLocation (String) Default: 0.0.0.0/0
Resources:
  2 AWS::AutoScaling::ScalingPolicy
  2 AWS::CloudWatch::Alarm
  1 AWS::AutoScaling::LaunchConfiguration
  1 AWS::ElasticLoadBalancingV2::LoadBalancer
  1 AWS::ElasticLoadBalancingV2::Listener
  1 AWS::ElasticLoadBalancingV2::TargetGroup
  1 AWS::SNS::Topic
  1 AWS::EC2::SecurityGroup
  1 AWS::AutoScaling::AutoScalingGroup
  9 Total
$
```

On the CloudFormation you will see the same resources:

<img src="/img/tutorial/autoscaling-resources.png" alt="Stack Created" class="doc-photo lono-flowchart">

Next, we'll edit the template.
