---
title: Cognito Authorizer
---

Cognito authorizers are also supported. Before integrating your API with a AWS Cognito user pool, you must create the user pool in Amazon Cognito. For instructions on how to create a user pool, see [Setting up User Pools](https://docs.aws.amazon.com/cognito/latest/developerguide/setting-up-cognito-user-identity-pools.html) in the Amazon Cognito Developer Guide. 
You can enable the Cognito authorizer by setting the type to `:cognito_user_pools`.
Example:

```ruby
class MainAuthorizer < ApplicationAuthorizer
  authorizer(
    name: "MyCognito", # <= name is used as the "function" name
    identity_source: "Authorization", # maps to method.request.header.Authorization
    type: :cognito_user_pools,
    provider_arns: [
      "arn:aws:cognito-idp:us-west-2:112233445566:userpool/us-west-2_DbXaf8jP7",
    ],
  )
  # no lambda function
end
```

Notice how there's no method defined underneath the `authorizer` declaration in the example. Cognito authorizers do not have Lambda functions associated with them unlike [Lambda authorizers]({% link _docs/routing/authorizers.md %}).

## Connecting to Routes

To connect the Cognito Authorizer to an [ApiGateway Method](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-method.html) use the `authorizer` property on a route.  Example:

config/routes.rb:

```ruby
Jets.application.routes.draw do
  # main#my_cognito => MainAuthorizer with the name MyCognito in app/authorizers/main_authorizer.rb
  get "hello", to: "posts#index", authorizer: "main#my_cognito"
  # ...
end
```

Since there is no Lambda function associated with the Cognito Authorizer, Jets uses the name of the authorizer itself.  You provide the underscored version of the name.

## Authorizer in Controllers

Cognito authorizers also can be set in the controller instead of the `routes.rb` file. Example:

```ruby
class PostsController < ApplicationController
  authorizer "main#my_cognito" # protects all actions in the controller
end
```

Setting the authorizer in the controller is just syntactical sugar. Ultimately, the authorizer is still set at the API Gateway Method Resource.

