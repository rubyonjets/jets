---
title: jets process:function
reference: true
---

## Usage

    jets process:function [event] [context] [handler]

## Description

Processes node shim job handler

Processes node shim job handler. The node shim spawns out to this command.

Example:

$ jets process function '{"key1":"value1"}' '{}' "handlers/function/hello.world"

## Options

```
[--verbose], [--no-verbose]  
[--noop], [--no-noop]        
```

