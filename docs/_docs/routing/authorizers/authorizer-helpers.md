---
title: Authorizer Helpers
nav_order: 32
---

The Authorizer Lambda function must return a response that conforms to the [Amazon API Gateway Lambda Authorizer Output](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-lambda-authorizer-output.html).  Jets provides some Authorizer Helpers to help generate the policy document response.

## Simple Examples

Here's the simplest form:

```ruby
def protect
  resource = event[:methodArn] # IE: arn:aws:execute-api:us-west-2:112233445566:ymy8tbxw7b/*/GET/my/path"
  build_policy(resource, "current_user")
end
```

The `build_policy` generates:

```json
{
  "principalId": "current_user",
  "policyDocument": [
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "execute-api:Invoke",
          "Effect": "Allow",
          "Resource": "arn:aws:execute-api:us-west-2:112233445566:f0ivxw7nkl/dev/GET/posts"
        }
      ]
    }
  ]
}
```

You can add `context` and `usage_identifier_key` as the 3rd and 4th parameters also:

```ruby
def protect
  resource = event[:methodArn] # IE: arn:aws:execute-api:us-west-2:112233445566:ymy8tbxw7b/*/GET/my/path"
  build_policy(resource, "current_user", { string_key: "value" }, "usage-key" )
end
```

It generates:

```json
{
  "principalId": "current_user",
  "context": {
    "stringKey": "value"
  },
  "policyDocument": [
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "execute-api:Invoke",
          "Effect": "Allow",
          "Resource": "arn:aws:execute-api:us-west-2:112233445566:f0ivxw7nkl/dev/GET/posts"
        }
      ]
    },
    {
      "StringKey": "value"
    }
  ],
  "usageIdentifierKey": "usage-key"
}
```

## General Form

The `build_policy` method also takes a hash in its generalized form. Here's an example:

```ruby
class MainAuthorizer < ApplicationAuthorizer
  authorizer(
    name: "MyAuthorizer",
    identity_source: "method.request.header.Authorization",
    type: "token", # valid values: token, cognito_user_pools, request. Jets upcases internally.
  )
  def protect
    resource = event[:methodArn] # IE: arn:aws:execute-api:us-west-2:112233445566:ymy8tbxw7b/*/GET/my/path"
    build_policy(
      principal_id: "current_user",
      policy_document: {
        version: "2012-10-17",
        statement: [
          action: "execute-api:Invoke",
          effect: "Allow",
          resource: resource,
        ],
      },
      context: {
        string_key: "value",
        number_key: "1",
        boolean_key: "true"
      },
      usage_identifier_key: "whatever",
    )
  end
end
```

The `build_policy` helper will pascalize and camelize the keys appropriately for the Authorizer Output. The `build_policy` method returns:

```json
{
  "principalId": "current_user",
  "policyDocument": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "execute-api:Invoke",
        "Effect": "Allow",
        "Resource": "arn:aws:execute-api:us-west-2:112233445566:f0ivxw7nkl/dev/GET/posts"
      }
    ]
  },
  "context": {
    "stringKey": "value",
    "numberKey": "1",
    "booleanKey": "true"
  },
  "usageIdentifierKey": "whatever"
}
```

{% include prev_next.md %}
