---
title: lono cfn current
reference: true
---

## Usage

    lono cfn current

## Description

Current stack that you're working with.

Set current values like stack name and suffix.

{% include current-options.md %}

## Static Example

    lono cfn create demo
    lono cfn current --name demo
    lono cfn update

## Suffix Example

    lono cfn current --suffix random
    lono cfn create demo
    lono cfn update demo-abc # generated random suffix was abc
    lono cfn current --name demo-abc
    lono cfn update
    lono cfn update # update again


## Options

```
[--rm], [--no-rm]            # Remove all current settings. Removes `.lono/current`
[--name=NAME]                # Current stack name.
[--suffix=SUFFIX]            # Current suffix for stack name.
[--verbose], [--no-verbose]
[--noop], [--no-noop]
```
