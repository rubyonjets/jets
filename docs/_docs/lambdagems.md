---
title: Lambda Gems
nav_order: 102
---

Jets deploy packages up the gems used by your application as part of the zip file and deploys it to AWS Lambda.  Most gems can be used with Lambda as-is because they are pure Ruby code. However, some gems use compiled native extensions. For example, nokogiri uses compiled native extensions. This presents a problem as your machine's architecture likely does not match the AWS Lambda environment's architecture.  The same compiled gems on your machine will not work on Lambda.

So Jets downloads pre-compiled gems from the [Lambda Gems](https://www.lambdagems.com) service. This makes for a much more seamless and pleasant developer experience. Lambda Gems will always be free for open source projects as long it continues to be sustainable.

## Custom Lambda Layers

For gems that are not provided by the Lambda Gems, you can build your own custom Lambda Layer and use it as part of your Jets project. Details here: [Custom Lambda Layers]({% link _docs/extras/custom-lambda-layers.md %}).

{% include prev_next.md %}
