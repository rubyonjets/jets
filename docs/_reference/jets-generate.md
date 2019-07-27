---
title: jets generate
reference: true
---

## Usage

    jets generate [type] [args]

## Description

Generates things like scaffolds.

This piggy backs off of the [jets scaffold generator](https://guides.rubyonjets.org/command_line.html#jets-generate).

## General options

    -h, [--help]     # Print generator's options and usage
    -p, [--pretend]  # Run but do not make any changes
    -f, [--force]    # Overwrite files that already exist
    -s, [--skip]     # Skip files that already exist
    -q, [--quiet]    # Suppress status output

Please choose a generator below.

Jets:

    application_record
    controller
    helper
    job
    migration
    model
    resource
    scaffold
    scaffold_controller
    task

ActiveRecord:

    active_record:application_record

## Options

```
[--noop], [--no-noop]  
```

