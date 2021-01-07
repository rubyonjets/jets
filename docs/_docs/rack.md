---
title: Rack Compatible
---

Jets is Rack compatible, both locally and remotely on AWS Lambda.

## What does Rack Compatibility mean?

[Rack](https://en.wikipedia.org/wiki/Rack_(web_server_interface)) is standard interface to build web applications in Ruby. Being Rack compatible means that Jets works according to the Rack standard.  This allows you to use other Rack components like middleware with Jets. Interestingly, this also allows you to run Jets on any rack compatible server like [puma](http://puma.io/) or [unicorn](https://bogomips.org/unicorn/).  So you could run your Jets web application on traditional EC2 servers if desired. Though Jets is built for the serverless world and AWS Lambda.

When you call a Lambda function that is a [Jets Controller]({% link _docs/controllers.md %}) it runs it through a set of Rack middlewares. You can see the full list of middleware with the [jets middleware](http://rubyonjets.com/reference/jets-middleware/) command.

If you are testing the Jets controller from the Lambda console, you don't really notice this as the Rack response is converted back to the AWS [Lambda AWS Proxy hash structure](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html) by the time it returns.

Locally when you run `jets server`, it starts up a rackup server and runs it through the same set of Rack middlewares.

