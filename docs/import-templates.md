---
title: Import Templates
---

Lono provides a handy `lono import` command. The command:

1. Downloads existing CloudFormation templates
2. Imports it into the lono with the right structure
3. Summarize the template's required parameters and resources

It gives you quick sense of how to use the downloaded template.  Let's use a simple sample template from the [AWS Samples documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/sample-templates-services-us-west-2.html#w2ab2c23c48c13c15).  The template creates an EC2 instance.

{% highlight bash %}
$ lono new infra
$ cd infra
# Import a starter template
$ lono import https://s3-us-west-2.amazonaws.com/cloudformation-templates-us-west-2/EC2InstanceWithSecurityGroupSample.template --name ec2
=> Imported CloudFormation template and lono-fied it.
Template definition added to app/definitions/base.rb
Params file created to config/params/base/ec2.txt
Template downloaded to app/templates/ec2.yml
=> CloudFormation Template Summary:
Parameters:
Required:
  KeyName (AWS::EC2::KeyPair::KeyName)
Optional:
  InstanceType (String) Default: t2.small
  SSHLocation (String) Default: 0.0.0.0/0
Resources:
  1 AWS::EC2::Instance
  1 AWS::EC2::SecurityGroup
  2 Total
Here are contents of the params config/params/base/ec2.txt file:
KeyName=
#InstanceType=        # optional
#SSHLocation=         # optional
$
{% endhighlight %}

We can see that this template has 1 required parameter called `KeyName`.  Let's set the parameter to a KeyName (assuming that the default KeyPair exists on your AWS account):

```
sed "s/KeyName=/KeyName=default/" config/params/base/ec2.txt > config/params/base/ec2.txt.1
mv config/params/base/ec2.txt{.1,}
```

Now we can launch the stack.

```
lono cfn create ec2 # launches stack
````

The `lono import` command gets you up and running with existing CloudFormation templates quickly.

Next, we'll cover how to some different ways to lono.

<a id="prev" class="btn btn-basic" href="{% link docs.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/install.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
