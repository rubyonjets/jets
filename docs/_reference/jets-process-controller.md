---
title: jets process:controller
reference: true
---

## Usage

    jets process:controller [event] [context] [handler]

## Description

Processes node shim controller handler

Processes node shim controller handler. The node shim spawns out to this command.

Example:

$ jets process:controller '{"pathParameters":{}}' '{"context":"data"}' "handlers/controllers/posts_controller.index"

$ jets process:controller '{"pathParameters":{"id":"tung"}}' '{}' handlers/controllers/posts_controller.show

## Options

```
[--verbose], [--no-verbose]  
[--noop], [--no-noop]        
```

