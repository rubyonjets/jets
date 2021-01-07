---
title: Authorizer Tips
---

Here are some tips for working with API Gateway Authorizers. The tips may help those who are newer to API Gateway Authorizers.

## Authorizer Type: Token

The token authorizer type is the simplest. The authorizer expects a secret token to pass in the header of the request. The header key is configured with the `identity_source` property.  Example:

```ruby
authorizer(
  name: "MyAuthorizer",
  identity_source: "Auth", # maps to method.request.header.Auth
  type: :token,
)
```

Example of passing the header with curl:

    curl -H "Auth: test" https://bxqim55nwg.execute-api.us-west-2.amazonaws.com/dev/protected/url

API Gateway converts the `Auth` Host header to `authorizationToken`. Make sure the request you send to your API Gateway endpoint has the header configured in the `identity_source`.

By the time it hits the Authorizer Lambda function it looks like this:

```json
{
    "type": "TOKEN",
    "methodArn": "arn:aws:execute-api:us-west-2:112233445566:bxqim55nwg/dev/GET/protected/url",
    "authorizationToken": "test"
}
```

So you send the token with the `Auth: test` header, but within the authorizer Lambda function, you grab the token with `event[:authorizationToken]`.

## Identity Source: Token

If the request does not include the host header that matches with the identity source, then the Lambda authorizer function does *not* even get called!  You'll get an `Unauthorized` response like so:

    $ curl -H "WrongHeader: test" https://bxqim55nwg.execute-api.us-west-2.amazonaws.com/dev/protected/url
    {"message":"Unauthorized"}

Remember even though you get a response. The response is from the AWS API Gateway side only. The request *never* hits your authorizer function.  Please make sure to pass the header that matches what's configured for `identity_source`.  Jets sets `Auth` as the default identity source header.

## Authorizer Type: Request

The request authorizer type is almost as simple as the token type. The Jets `authorizer` method uses it as the default type.  With the request type, you have more control over what items get passed to the authorizer function.  You receive a fuller event payload in this structure:

```json
{
    "type": "REQUEST",
    "methodArn": "arn:aws:execute-api:us-west-2:112233445566:lntmrm92ba/dev/GET/my/path",
    "resource": "/my/path",
    "path": "/my/path",
    "httpMethod": "GET",
    "headers": {
        "headerauth1": "headerValue1",
        ...
    },
    "multiValueHeaders": {...},
    "queryStringParameters": {
        "QueryString1": "queryValue1"
    },
    "multiValueQueryStringParameters": {..},
    "pathParameters": {},
    "stageVariables": {},
    "requestContext": {
        ...
        "identity": {
            "cognitoIdentityPoolId": null,
            ...
            "cognitoAuthenticationType": null,
            "cognitoAuthenticationProvider": null,
        },
        "domainName": "lntmrm92ba.execute-api.us-west-2.amazonaws.com",
        "apiId": "lntmrm92ba"
    }
}
```

## Identity Sources: Request

For request type authorizers, the identity sources can be request headers, query string parameters, stage names, and or context variables. They are set as a comma-separated list on the `identity_source` property.  Example:

```ruby
authorizer(
  name: "MyAuthorizer",
  identity_source: "method.request.header.Header1,method.request.querystring.QueryString1",
  type: :request,
)
```

All identity sources must be provided with the request. If the request does not pass all the items in the identity_source list, then the Lambda authorizer function does *not* even get called!  Remember to send them all. Example:

    curl -H "Header1: test" "https://bxqim55nwg.execute-api.us-west-2.amazonaws.com/dev/protected/url?QueryString1=test"

## Disable Caching First

When working with authorizers for the first time, it will likely help if you disable caching.  Jets does not set the `ttl` property by default. So by default,  caching is disabled.

Note, the CloudFormation docs state that the default ttl is 300, but that only seems to be with the API Gateway console.

