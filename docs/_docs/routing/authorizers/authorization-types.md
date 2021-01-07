---
title: Authorization Types
---

By default, calling API Gateway does not require authorization. You can add authorization to your API with [API Gateway authorizers]({% link _docs/routing/authorizers.md %}) and authorization types. There are several authorization types available:

* NONE - open access
* AWS_IAM - use [AWS IAM](https://aws.amazon.com/iam/) permissions
* CUSTOM - custom authorizer
* COGNITO\_USER\_POOLS - [Cognito](https://aws.amazon.com/cognito/) User Pool

The complete list of authorization types is available in the [AWS API Gateway docs](https://docs.aws.amazon.com/apigateway/api-reference/resource/method/#authorizationType).

### Application Wide

You can enable authorization application-wide with `config/application.rb`:

```ruby
Jets.application.configure do
  config.api.authorization_type = :aws_iam
end
```

This will require a caller to authenticate using IAM before being able to access the endpoint.

### Controller Wide

You can enable controller-wide authorization also.  Example:

```ruby
class PostsController < ApplicationController
  authorization_type :aws_iam
end
```

All PostsController actions will be using `AWS_IAM` authorization.

### Route Specific

You can also enable authorization on a per-route basis with the `authorization_type` option:

```ruby
Jets.application.routes.draw do
  get  "posts", to: "posts#index", authorization_type: :aws_iam
end
```

### Inferred Authorization Type

When using [Jets Authorizers]({% link _docs/routing/authorizers.md %}), Jets will infer the right `authorization_type` for `CUSTOM` and `COGNITO_USER_POOLS` types. So it is recommended to only set authorization_type when you're using other types like `AWS_IAM`.

