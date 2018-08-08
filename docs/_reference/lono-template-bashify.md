---
title: lono template bashify
reference: true
---

## Usage

    lono template bashify URL-OR-PATH

## Description

Convert the UserData section of an existing CloudFormation Template to a starter bash script that is compatiable with lono

## Examples

    lono template bashify /path/to/cloudformation-template.json
    lono template bashify https://s3.amazonaws.com/cloudformation-templates-us-east-1/EC2WebSiteSample.template


## Options

```
[--quiet], [--no-quiet]  # silence the output
[--noop], [--no-noop]    # noop mode, do nothing destructive
```
