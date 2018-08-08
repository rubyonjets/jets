---
title: lono import
reference: true
---

## Usage

    lono import SOURCE

## Description

Imports CloudFormation template and lono-fies it.

## Examples

    lono import /path/to/file --name my-stack
    lono import http://url.com/path/to/template.json --name my-stack
    lono import http://url.com/path/to/template.yml --name my-stack

## Example Output

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

### Template name: CamelCase or dasherize

If you do not specify the `--name` option, `lono import` sets a name based on the filename of the imported file.  It converts the name to a dasherize version of the filename by default.

You can specify whether or not to CamelCase or dasherize the name of the final template file with the `--casing` option.  Examples:

Dasherize:

```sh
lono import https://s3.amazonaws.com/cloudformation-templates-us-east-1/EC2InstanceWithSecurityGroupSample.template --casing dasherize
```

CamelCase:

```sh
lono import https://s3.amazonaws.com/cloudformation-templates-us-east-1/EC2InstanceWithSecurityGroupSample.template --casing camelcase
```

The default is dasherize.

Question: You might be wondering, why does lono import uses dasherize vs underscore?

Answer: I prefer filenames to be underscored. However, CloudFormation stack names do not allow underscores in their naming, so it is encourage to either dasherize or camelize your template names so the stack name and the template name can be the same.

This blog post [Introducing the lono import Command](https://blog.boltops.com/2017/09/15/introducing-the-lono-import-command) also covers `lono import`.


## Options

```
[--name=NAME]                # final name of downloaded template without extension
[--casing=CASING]            # camelcase or dasherize the template name
                             # Default: dasherize
[--summary], [--no-summary]  # provide template summary after import
                             # Default: true
```
