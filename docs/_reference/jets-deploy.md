---
title: jets deploy
reference: true
---

## Usage

    jets deploy [environment]

## Description

Deploys project to Lambda

Builds and deploys project to AWS Lambda.  This creates and or updates the CloudFormation stack.

$ jets deploy

## Options

```
[--capabilities=one two three]  # iam capabilities. Ex: CAPABILITY_IAM, CAPABILITY_NAMED_IAM
[--iam], [--no-iam]             # Shortcut for common IAM capabilities: CAPABILITY_IAM, CAPABILITY_NAMED_IAM
[--noop], [--no-noop]           
```

