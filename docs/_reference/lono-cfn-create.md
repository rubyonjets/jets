---
title: lono cfn create
reference: true
---

## Usage

    lono cfn create STACK

## Description

Create a CloudFormation stack using the generated template.

## Examples

Provided that you are in a lono project and have a `my-stack` lono template definition.  To create a stack you can run:

    lono cfn create my-stack

The above command will generate and use the template in `output/templates/my-stack.json` and parameters in `output/params/my-stack.txt`.  By [convention]({% link _docs/conventions.md %}), the template defaults to the name of the stack.  In turn, the params defaults to the name of the template.

Here are examples of overriding the template and params name conventions.

    lono cfn create my-stack --template different1

The template used is `output/templates/different1.json` and the parameters used is `output/params/different1.json`.

    lono cfn create my-stack --param different2

The template used is `output/templates/my-stack.json` and the parameters used is `output/params/different2.json`.

    lono cfn create my-stack --template different3 --param different4

The template used is `output/templates/different3.json` and the parameters used is `output/params/different4.json`.


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
[--wait], [--no-wait]           # Wait for stack operation to complete.
                                # Default: true
[--verbose], [--no-verbose]
[--noop], [--no-noop]
```
