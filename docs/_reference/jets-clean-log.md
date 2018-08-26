---
title: jets clean:log
reference: true
---

## Usage

    jets clean:log

## Description

Cleans CloudWatch log groups assocated with app.

Essentially removes the CloudWatch groups assocated with the app. Lambda requests re-create the log groups so this is pretty safe to do.

## Example

    jets log:clean

## Options

```
[--noop], [--no-noop]  # noop or dry-run mode
[--mute], [--no-mute]  # mute output
[--sure], [--no-sure]  # bypass are you sure prompt
```

