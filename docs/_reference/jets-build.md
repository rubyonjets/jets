---
title: jets build
reference: true
---

## Usage

    jets build

## Description

Builds and packages project for AWS Lambda.

Builds a zip file package to be uploaded to AWS Lambda. This allows you to build the project without deploying and inspect the zip file that gets deployed to AWS Lambda. The package contains:

* your application code
* generated node shims
* bundled gems
* bundled Ruby

If the application has no ruby code and only uses polymorphic functions, then gems and Ruby is not bundled up.

## Options

```
[--templates-only], [--no-templates-only]  # provide a way to skip building the code and only build the CloudFormation templates
[--force-full], [--no-force-full]          # For a fake full build even if the stack does not exist
[--noop], [--no-noop]                      
```

