---
title: jets build
reference: true
---

## Usage

    jets build

## Description

Builds and packages project for AWS Lambda.

Generates a node shim and bundles a Linux Ruby in the bundled folder.  Creates a zip file to be uploaded to Lambda for each handler. This allows you to build the project and inspect the zip file that gets deployed to AWS Lambda.

## Options

```
[--templates-only], [--no-templates-only]  # provide a way to skip building the code and only build the CloudFormation templates
[--noop], [--no-noop]                      
```

