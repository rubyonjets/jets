---
title: "Tutorial: Import Auto Scaling Template"
---

## Import Template

Let's grab an AutoScaling template from [CloudFormation Auto Scaling Samples](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/sample-templates-services-us-west-2.html#w2ab2c23c48c13b7).  We'll grab the "Load-based auto scaling" example and run the `lono import` command with it.  We'll use the `--name autoscaling` option to set the imported template name.

```
$ cd autoscaling # cd into the newly created project if you havent already
$ lono import https://s3-us-west-2.amazonaws.com/cloudformation-templates-us-west-2/AutoScalingMultiAZWithNotifications.template --name autoscaling
=> Imported CloudFormation template and lono-fied it.
Template definition added to app/definitions/base.rb
Params file created to config/params/base/autoscaling.txt
Template downloaded to app/templates/autoscaling.yml
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
Here are contents of the params config/params/base/autoscaling.txt file:
VpcId=
Subnets=
OperatorEMail=
KeyName=
#InstanceType=        # optional
#SSHLocation=         # optional
$
```

The output tells you what happened, but here's addiitonal explanation of what `lono import` did:

* A template definition was added to the `app/definitions/base.rb`.
* A lono env-like params file was created at `config/params/base/autoscaling.txt`.
* The CloudFormation template was downloaded to `app/templates/autoscaling.yml`
* A summary of the CloudFormation template was provided.  The required parameters to use the template are worth noting.
* The contents of the `config/params/base/autoscaling.txt` params file is shown so you know what to edit.

## Looking at the Generated Files

Let's look at the files that were created by `lono import`.

### app/templates/autoscaling.yml

The `app/templates/autoscaling.yml` is simply the template that was imported into the lono project. If the original template's format was JSON, lono converts the template into YAML.  If the original format was YAML, lono imports the template as is.

### app/definitions/base.rb

Even though the template exists in the `app/templates` folder, a template definition in `app/definitions` is required to tell lono to generate to template to the `outputs` folder.  Here are the contents of `app/definitions/base.rb`:

```ruby
template "autoscaling"
```

It's just simple one line template definition.  `lono import` added the template definition.

### config/params/base/autoscaling.txt

The generated params file is interesting. Here are the contents of `config/params/base/autoscaling.txt`:

```
VpcId=
Subnets=
OperatorEMail=
KeyName=
#InstanceType=        # optional
#SSHLocation=         # optional
```

We can tell that we need to set the `VpcId`, `Subnets`, `OperatorEMail`, and `KeyName` template parameters to use the template.

## Configure Parameter Values

For the sake of this guide, we'll use the default VPC and subnets. You can use the following commands to set bash variables that we'll use to set the required parameters:

```
VPC=$(aws ec2 describe-vpcs | jq -r '.Vpcs[] | select(.IsDefault == true) | .VpcId')
SUBNETS=$(aws ec2 describe-subnets | jq -r '.Subnets[].SubnetId' | tr -s '\n' ',' | sed 's/,*$//g')
EMAIL=email@domain.com
KEY_NAME=default
```

Now update the required parameters with `sed`:

```
sed "s/VpcId=/VpcId=$VPC/; s/Subnets=/Subnets=$SUBNETS/; s/OperatorEMail=/OperatorEMail=$EMAIL/; s/KeyName=/KeyName=$KEY_NAME/;" config/params/base/autoscaling.txt > config/params/base/autoscaling.txt.1
mv config/params/base/autoscaling.txt{.1,}
```

Everything is now configured and we are ready to launch the the stack next!
