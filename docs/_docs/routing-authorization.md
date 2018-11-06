---
title: Authorization
---

## Authorization

By default, each route does not require any authorization. You can enable authorization application-wide with `config/application.rb`:

```ruby
Jets.application.configure do
  config.api.authorization_type = "AWS_IAM"
end
```

This will require a caller to authenticate using IAM before being able to access the endpoint.

You can also enable authorization on a per-route basis with the `authorization_type` option:

```ruby
Jets.application.routes.draw do
  get  "posts", to: "posts#index", authorization_type: "AWS_IAM"
end
```

The complete list of authorization types is available in the [AWS API Gateway docs](https://docs.aws.amazon.com/apigateway/api-reference/resource/method/#authorizationType).

<a id="prev" class="btn btn-basic" href="{% link _docs/routing-overview.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/routing-custom-domain.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
