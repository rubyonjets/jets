---
title: jets delete
reference: true
---

## Usage

    jets delete

## Description

Delete the Jets project and all its resources.

This essentially deletes the associated CloudFormation stacks.

## Examples

    $ jets delete

You can bypass the are you sure prompt with the `--sure` flag.

    $ jets delete --sure

## Options

```
[--sure], [--no-sure]  # Skip are you sure prompt.
[--wait], [--no-wait]  # Wait for stack deletion to complete.
                       # Default: true
[--noop], [--no-noop]  
```

