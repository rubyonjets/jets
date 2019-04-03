---
title: Authorization
nav_order: 31
---

## Authorization

By default, calling API Gateway does not require authorization. You can add authorization to your API with API Gateway authorization types. There are several authorization types available:

* NONE - open access
* AWS_IAM - use [AWS IAM](https://aws.amazon.com/iam/) permissions
* CUSTOM - custom authorizer
* COGNITO_USER_POOLS - [Cognito](https://aws.amazon.com/cognito/) User Pool

The complete list of authorization types is available in the [AWS API Gateway docs](https://docs.aws.amazon.com/apigateway/api-reference/resource/method/#authorizationType).

You can also make use of [Before Filters]({% link _docs/extras/action-filters.md %}) to build your own custom authorization system instead of using API Gateway Authorization types.

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

All PostsController actions will be use `AWS_IAM` authorization.

### Route Specific

You can also enable authorization on a per-route basis with the `authorization_type` option:

```ruby
Jets.application.routes.draw do
  get  "posts", to: "posts#index", authorization_type: :aws_iam
end
```

{% include prev_next.md %}