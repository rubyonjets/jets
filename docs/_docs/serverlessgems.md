---
title: Serverless Gems
---

Jets deploy packages up the gems used by your application as part of the zip file and deploys it to AWS Lambda.  Most gems can be used with Lambda as-is because they are pure Ruby code. However, some gems use compiled native extensions. For example, nokogiri uses compiled native extensions. This presents a problem as your machine's architecture likely does not match the AWS Lambda environment's architecture.  The same compiled gems on your machine will not work on Lambda.

So Jets downloads pre-compiled gems from the [Serverless Gems](https://www.serverlessgems.com) service. This makes for a seamless and pleasant developer experience. Serverless Gems will free for open-source projects as long it continues to be sustainable.

If you wish to remove the call to Serverless Gems, you can configure your Jets app like so:

```ruby
Jets.application.configure do
  config.gems.disable = true
end
```

This means that any binary gems your Jets app requires will not work on on AWS Lambda, unless you've built your own custom lambda layer.

## Custom Lambda Layers

For gems that are not provided by the Serverless Gems, you can build your own custom Lambda Layer and use it as part of your Jets project. Details here: [Custom Lambda Layers]({% link _docs/extras/custom-lambda-layers.md %}).

