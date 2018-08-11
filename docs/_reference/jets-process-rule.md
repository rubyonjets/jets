---
title: jets process:rule
reference: true
---

## Usage

    jets process:rule [event] [context] [handler]

## Description

Processes node shim rule handler.

The node shim spawns out to this command.

## Example

    $ jets process:rule file://config_change.json '{"context":"data"}' "handlers/rules/game_rule.protect"

## Options

```
[--verbose], [--no-verbose]  
[--noop], [--no-noop]        
```

