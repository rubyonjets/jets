---
title: Custom Lambda Layers
---

You can include and use your own [Custom Lambda Layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html). This allows you to handle cases of extra customization like additional system libraries and gems.  Here's how you configure custom Lambda Layers.

```ruby
Jets.application.configure do
  config.lambda.layers = [
    "arn:aws:lambda:us-west-2:112233445566:layer:my-layer:2",
    "arn:aws:lambda:us-west-2:112233445566:layer:another-layer:8",
  ]
end
```

Jets uses one layer for the [Gem Layer]({% link _docs/gem-layer.md %}). The current max Lambda Layers is 5, so this means you can add up to 4 of your own custom layers.

<a id="prev" class="btn btn-basic" href="{% link _docs/custom-lambda-layers.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/polymorphic-python.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
