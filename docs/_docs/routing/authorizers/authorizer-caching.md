---
title: Authorizer Caching
nav_order: 35
---

You can cache the authorizer with the `ttl` convenience property. This means the Authorizer lambda function will not be called again until the ttl expires. Example:

```ruby
authorizer(
  name: "MainProtect",  # required
  ttl: 60,
)
```

The `ttl` option is shorthand for the `authorizer_result_ttl_in_seconds` property associatd with the CloudFormation [ApiGateway::Authorizer](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-authorizer.html) properties.

{% include prev_next.md %}