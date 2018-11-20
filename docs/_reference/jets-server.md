---
title: jets server
reference: true
---

## Usage

    jets server

## Description

Runs a local server that mimics API Gateway for development.

The local server for mimics API Gateway and provides a way to test your app locally without deploying to AWS.

## Examples

    $ jets server
    => bundle exec shotgun --port 8888 --host 127.0.0.1
    Jets booting up in development mode!
    == Shotgun/WEBrick on http://127.0.0.1:8888/
    [2018-08-17 05:31:33] INFO  WEBrick 1.4.2
    [2018-08-17 05:31:33] INFO  ruby 2.5.1 (2018-03-29) [x86_64-linux]
    [2018-08-17 05:31:33] INFO  WEBrick::HTTPServer#start: pid=27433 port=8888

Start up server binding to host `0.0.0.0`:

    jets server --host 0.0.0.0

## Options

```
[--port=PORT]              # use PORT
                           # Default: 8888
[--host=HOST]              # listen on HOST
                           # Default: 127.0.0.1
[--reload], [--no-reload]  # Enables hot-reloading for development
                           # Default: true
[--noop], [--no-noop]      
```

