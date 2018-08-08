---
title: Import Template
---

Lono provides a `lono import` command to spare you from manually having to convert a standard CloudFormation template into a lono CloudFormation template.  Usage:

```sh
$ lono import https://s3.amazonaws.com/cloudformation-templates-us-east-1/EC2InstanceWithSecurityGroupSample.template --name ec2
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
```

You can also specify standard file paths:

```sh
lono import path/to/template
```

The command downloads the template to `templates` folder, converts it into YAML, and declares a new template definition in `app/definitions/base.rb`.

You can `lono generate` immediately after the `lono import` command to generate a template in the `output/templates` folder.

```sh
lono generate
```

This blog post [Introducing the lono import Command](https://blog.boltops.com/2017/09/15/introducing-the-lono-import-command) also covers `lono import`.

<a id="prev" class="btn btn-basic" href="{% link _docs/lono-env.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/app-definitions.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
