---
title: lono cfn diff
reference: true
---

## Usage

    lono cfn diff STACK

## Description

Diff newly generated template vs existing template.

Displays code diff of the generated CloudFormation template locally vs the existing template on AWS. You can set a desired diff viewer by setting the `LONO_DIFF` environment variable.

## Examples

    $ lono cfn diff ec2
    Using template: output/templates/ec2.yml
    Using parameters: config/params/development/ec2.txt
    No detected app/scripts
    Generating CloudFormation templates:
      output/templates/ec2.yml
      output/params/ec2.json
    Generating CloudFormation source code diff...
    Running: colordiff /tmp/existing_cfn_template.yml output/templates/ec2.yml
    19c19
    <     Default: t2.small
    ---
    >     Default: t2.medium
    $ subl -a ~/.lono/settings.yml
    $

Here's a screenshot of the output with the colorized diff:

<img src="/img/reference/lono-cfn-diff.png" alt="Stack Update" class="doc-photo">

A `lono cfn diff` is perform automatically as part of `lono cfn update`.


## Options

```
[--template=TEMPLATE]           # override convention and specify the template file to use
[--param=PARAM]                 # override convention and specify the param file to use
[--lono], [--no-lono]           # invoke lono to generate CloudFormation templates
                                # Default: true
[--capabilities=one two three]  # iam capabilities. Ex: CAPABILITY_IAM, CAPABILITY_NAMED_IAM
[--iam], [--no-iam]             # Shortcut for common IAM capabilities: CAPABILITY_IAM, CAPABILITY_NAMED_IAM
[--rollback], [--no-rollback]   # rollback
                                # Default: true
[--verbose], [--no-verbose]
[--noop], [--no-noop]
```
