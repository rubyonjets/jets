---
title: lono cfn download
reference: true
---

## Usage

    lono cfn download STACK

## Description

Download CloudFormation template from existing stack.

## Examples

    lono cfn download my-stack


## Options

```
[--name=NAME]                   # Name you want to save the template as. Default: existing stack name.
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
