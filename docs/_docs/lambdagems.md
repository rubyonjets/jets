---
title: Lambda Gems
---

Jets deploy packages up the gems used by your application as part of the zip file and deploys it to AWS Lambda.  Most gems can be used with Lambda as-is because they are pure Ruby code. However, some gems use compiled native extensions. For example, nokogiri uses compiled native extensions. This presents a problem as your machine's architecture likely does not match the AWS Lambda environment's architecture.  The same compiled gems on your machine will not work on Lambda.

So Jets downloads pre-compiled gems from the [Lambda Gems](https://www.lambdagems.com) service. This makes for a much more seamless and pleasant developer experience. Lambda Gems will always be free for open source projects as long it continues to be sustainable.

## Custom Lambda Layers

For gems that are not provided by the Lambda Gems, you can build your own custom Lambda Layer and use it as part of your Jets project. Details here: [Custom Lambda Layers]({% link _docs/custom-lambda-layers.md %}).

<a id="prev" class="btn btn-basic" href="{% link faq.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/contributing.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
