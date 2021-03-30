---
title: Gem Layer
---

Jets bundles your project's gem dependencies in a Gem Layer which is a [Lambda Layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html). From the AWS Docs:

> With layers, you can use libraries in your function without needing to include them in your deployment package.

## Advantages of Gem Layer

A key advantage is that it results in your code size being smaller. If your application code is under the key [3 MB](https://docs.aws.amazon.com/lambda/latest/dg/limits.html) limit, you are able to see and edit your Lambda code in the AWS Lambda console code editor **live**.  This is extremely helpful to debug and test without a full deploy.

An additional advantage of using a separate Gem Layer is that this allows Jets to optimize the deploy process and upload the gems only to s3 only when they change.  AWS designed Lambda Layers understanding this benefit. On a slow internet connection this significantly improves your [development speed]({% link _docs/faster-development.md %}) and happiness.

