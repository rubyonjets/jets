---
title: jets process:job
reference: true
---

## Usage

    jets process:job [event] [context] [handler]

## Description

Processes node shim job handler.

The node shim spawns out to this command.

## Example

    $ jets process:job '{"we":"love", "using":"Lambda"}' '{"context":"data"}' "handlers/jobs/hard_job.dig"

## Options

```
[--verbose], [--no-verbose]  
[--noop], [--no-noop]        
```

