---
title: "Tutorial EC2: Import EC2 Template"
---

## Import Template

Let's grab an AutoScaling template from [Amazon EC2 instance in a security group  ](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/sample-templates-services-us-west-2.html#w2ab2c23c48c13c15).  We'll grab the "Amazon EC2 instance in a security group" example and run the `lono import` command with it.  We'll use the `--name ec2` option to set the imported template name.

```
$ cd ec2 # cd into the newly created project if you haven't already
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
```

The output tells you what happened, but here's additional explanation of what `lono import` did:

* A template definition was added to the `app/definitions/base.rb`.
* A lono env-like params file was created at `config/params/base/ec2.txt`.
* The CloudFormation template was downloaded to `app/templates/ec2.yml`
* A summary of the CloudFormation template was provided.  The required parameters to use the template are worth noting.
* The contents of the `config/params/base/ec2.txt` params file is shown, so you know what to edit.

## Looking at the Generated Files

Let's look at the files that were created by `lono import`.

### app/templates/ec2.yml

The `app/templates/ec2.yml` is simply the template that was imported into the lono project. If the original template's format was JSON, lono converts the template into YAML.  If the original format was YAML, lono imports the template as is.

### app/definitions/base.rb

Even though the template exists in the `app/templates` folder, a template definition in `app/definitions` is required to tell lono to generate to the template to the `outputs` folder.  Here are the contents of `app/definitions/base.rb`:

```ruby
template "ec2"
```

It's just simple one line template definition.  `lono import` added the template definition.

### config/params/base/ec2.txt

The generated params file is interesting. Here are the contents of `config/params/base/ec2.txt`:

```
KeyName=
#InstanceType=        # optional
#SSHLocation=         # optional
```

We can tell that we need to set the `KeyName` parameter to use the template.

## Configure Parameter Values

For this template, we need to specify a `KeyName` so we can ssh into the EC2 instance.  Set the `KeyName` to an ssh key that exists on your AWS account. We'll set it to `default` here.  If you use `default`, make sure that the `default` KeyPair exists on your account.

`config/params/base/ec2.txt`:

```
KeyName=default
#InstanceType=        # optional
#SSHLocation=         # optional
```

Everything is now configured, and we are ready to launch the stack next!

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorials/ec2/project-structure.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorials/ec2/cfn-create.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
