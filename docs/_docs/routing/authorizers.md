---
title: Authorizers
---

Jets supports writing [Lambda Authorizers](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html).  You define them in the `app/authorizers` folder. Here's an example:

app/authorizers/main_authorizer.rb:

```ruby
class MainAuthorizer < ApplicationAuthorizer
  authorizer(
    name: "MyAuthorizer",
    identity_source: "Auth", # maps to method.request.header.Auth
    type: :request, # valid values: token, cognito_user_pools, request. Jets upcases internally.
  )
  def protect
    # Must conform to Amazon API Gateway Lambda Authorizer Output structure
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-lambda-authorizer-output.html
    resource = event[:methodArn] # IE: arn:aws:execute-api:us-west-2:112233445566:ymy8tbxw7b/*/GET/my/path"
    {
      "principalId" => "current_user_id", # replace with the current user id
      "policyDocument" => {
        "Version" => "2012-10-17",
        "Statement" => [
          {
            "Action" => "execute-api:Invoke",
            "Effect" => "Allow",
            "Resource" => resource
          }
        ]
      }
    }
  end
end
```

The `authorizer` keyword builds an ApiGateway Authorizer. The authorizer options map to CloudFormation [ApiGateway::Authorizer](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-authorizer.html) properties. You can use any of the properties supported by CloudFormation. The authorizer is associated with the Lambda function directly below it.

The Lambda function must return a response in the [Amazon API Gateway Lambda Authorizer Output structure](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-lambda-authorizer-output.html).  The example above builds the raw structure, you may also be interested in the [build_policy helper]({% link _docs/routing/authorizers/authorizer-helpers.md %}).

## ApplicationAuthorizer

If your project does not yet have the `ApplicationAuthorizer` yet, you can simply add it.

app/authorizers/application_authorizer.rb:

```ruby
class ApplicationAuthorizer < Jets::Authorizer::Base
end
```

## Connecting to Routes

To connect the Authorizer to an [ApiGateway Method](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-method.html) use the `authorizer` property on a route.  Example:

config/routes.rb:

```ruby
Jets.application.routes.draw do
  # main#protect => MainAuthorizer#protect in app/authorizers/main_authorizer.rb
  get "hello", to: "posts#index", authorizer: "main#protect"
  # ...
end
```

When the `authorizer` property is used, the `authorization_type` is inferred from the authorizer property and automatically set for you. The `authorization_type` can be overridden by setting it explicitly. Refer to the [Authorization Types docs]({% link _docs/routing/authorizers/authorization-types.md %}) for more info.  For `CUSTOM` AND `COGNITO_USER_POOLS` authorization types, it is recommended to let Jets handle it. For the `AWS_IAM` type you will need to handle it appropriately.

## Authorizer in Controllers

You can set the authorizer in the controller instead of the `routes.rb` file. Example:

```ruby
class PostsController < ApplicationController
  authorizer "main#protect" # protects all actions in the controller
end
```

You can also use `only` and `except` options to select which actions to protect.

```ruby
class PostsController < ApplicationController
  authorizer "main#protect", only: %w[index]
end
```

An `except` example:

```ruby
class PostsController < ApplicationController
  authorizer "main#protect", except: %w[index]
end
```

Setting the authorizer in the controller is just syntactical sugar. Ultimately, the authorizer is still set at the API Gateway Method Resource.

## Test Authorizer

To test the Authorizer, send a request with the `Auth` header and one without it.  Here's an example:

    $ URL=https://wmtqdx6byd.execute-api.us-west-2.amazonaws.com/dev/posts # use your own URL
    $ curl -H "Auth: test" $URL -vso /dev/null 2>&1 | grep '< HTTP'
    < HTTP/2 200
    $ curl $URL -vso /dev/null 2>&1 | grep '< HTTP'
    < HTTP/2 401
    $

## Authorizer Defaults

The `authorizer` method has some conventional defaults.  The following:

```ruby
authorizer(
  name: "MyAuthorizer",
)
```

Is the same as:

```ruby
authorizer(
  name: "MyAuthorizer",
  identity_source: "Auth",
  type: :request,
)
```

The only required option for the `authorizer` method is `name`.  Also, the default `identity_source` can be configured with `config.api.authorizers.default_token_source`.

```ruby
Jets.application.configure do
  config.api.authorizers.default_token_source = "Auth" # method.request.header.Auth
end
```

## Identity Source Convention

You may have noticed `identity_source` understands a shorthand value: `identity_source: "Auth"`. Jets expands it out to `method.request.header.Auth`. For example:

```ruby
authorizer(
  name: "MyAuthorizer",
  identity_source: "Auth",
)
```

is the same as:

```ruby
authorizer(
  name: "MyAuthorizer",
  identity_source: "method.request.header.Auth",
)
```

If the `identity_source` value contains a `.` then Jets leaves it as-is. If it does not, then it will conventionally adds `method.request.header.`.  This also applies to comma-separated `identity_source` values.  Jets expands each item without a `.`.

## Authorizer Name Workaround

The [ApiGateway::Authorizer](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-authorizer.html#cfn-apigateway-authorizer-name) CloudFormation docs state that the name is not required, but, in testing, have found it to be required.  If you rename the lambda function or reassociate the authorizer with another Lambda function, the stack may roll back from a naming collision. To work around this, rename the authorizer for that deploy.  Example:

```ruby
class MainAuthorizer < ApplicationAuthorizer
  authorizer(
    name: "MyAuthorizer2", # <= Change this
    identity_source: "Auth", # maps to method.request.header.Auth
    type: :request, # valid values: token, cognito_user_pools, request. Jets upcases internally.
  )
  # ...
end
```

## Before Filters

Note: You can also make use of [Before Filters]({% link _docs/extras/action-filters.md %}) to build your own custom authorization system instead of using API Gateway Authorizers.

