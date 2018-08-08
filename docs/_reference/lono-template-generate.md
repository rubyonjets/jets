---
title: lono template generate
reference: true
---

## Usage

    lono template generate

## Description

Generate the CloudFormation templates

## Examples

    lono template generate
    lono template generate --clean
    lono template g --clean

Builds the CloudFormation templates files based on lono project and writes them to the output folder on the filesystem.


## Options

```
[--clean], [--no-clean]  # remove all output files before generating
[--quiet], [--no-quiet]  # silence the output
[--noop], [--no-noop]    # noop mode, do nothing destructive
```
