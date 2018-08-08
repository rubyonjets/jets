---
title: lono generate
reference: true
---

## Usage

    lono generate

## Description

Generate both CloudFormation templates and parameters files.

Generates CloudFormation template, parameter files, and scripts in lono project and writes them to the `output` folder.

## Examples

    lono generate
    lono generate --clean
    lono g --clean # shortcut

## Example Output

    $ lono generate
    Generating CloudFormation templates, parameters, and scripts
    No detected app/scripts
    Generating CloudFormation templates:
      output/templates/ec2.yml
    Generating parameter files:
      output/params/ec2.json
    $


## Options

```
[--clean], [--no-clean]  # remove all output files before generating
                         # Default: true
[--quiet], [--no-quiet]  # silence the output
```
