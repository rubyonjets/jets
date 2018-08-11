---
title: jets deploy
reference: true
---

## Usage

    jets deploy [environment]

## Description

Builds and deploys project to AWS Lambda.

This packages up the project and deploys it AWS Lambda. This essentially updating the CloudFormation stack.

## Example

    $ jets deploy

## Options

```
[--capabilities=one two three]  # iam capabilities. Ex: CAPABILITY_IAM, CAPABILITY_NAMED_IAM
[--iam], [--no-iam]             # Shortcut for common IAM capabilities: CAPABILITY_IAM, CAPABILITY_NAMED_IAM
[--noop], [--no-noop]           
```

