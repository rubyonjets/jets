---
title: API Gateway Routes
---

Jets translates `config/routes.rb` definitions to API Gateway Resources: [Routing Overview](http://rubyonjets.com/docs/routing-overview/). Essentially, API Gateway is the routing layer of a Jets application.  From the [AWS API Gateway](https://aws.amazon.com/api-gateway/) product page:

>  You can create REST and WebSocket APIs that act as a “front door” for applications to access data, business logic, or functionality from your backend services, such as workloads running on Amazon Elastic Compute Cloud (Amazon EC2), code running on AWS Lambda, any web application, or real-time communication applications.

As Jets leverages API Gateway, we should consider and understand the way API Gateway works, its limits, and its benefits.

## Sibling Variable Limit

API Gateway allows the use of one variable path under a parent path. Here's an example with a variable of `:id` under the parent path `posts/`:

```ruby
Jets.application.routes.draw do
  get  "posts/:id", to: "posts#show"
  get  "posts/:id/edit", to: "posts#edit"
end
```

API does not currently support multiple sibling variables under the same parent path. For example, the following does not work:

`config/routes.rb`

```ruby
Jets.application.routes.draw do
  get  "posts/:id", to: "posts#show"
  # :post_id and :id are siblings with same parent `posts` - only 1 sibling variable is allowed
  get  "posts/:post_id/edit", to: "posts#edit"
end
```

To fix this you must rename `:post_id` to `:id`.

### More Details

When you try to deploy this, it will fail with an error that looks something like this:

    $ jets deploy
    ...
    Deploying CloudFormation stack with jets app!
    11:29:43PM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack demo-dev User Initiated
    ...
    11:30:01PM UPDATE_FAILED AWS::CloudFormation::Stack ApiGateway Embedded stack arn:aws:cloudformation:us-west-2:536766270177:stack/demo-dev-ApiGateway-154WB3G5JW51D/9725de30-19e4-11e9-8459-0688a7bf983a was not successfully updated. Currently in UPDATE_ROLLBACK_IN_PROGRESS with reason: The following resource(s) ...
    $

Going to the `ApiGateway Embedded stack` child stack allows you to see see the error details:

> A sibling ({id}) of this resource already has a variable path part -- only one is allowed

![](/img/docs/cloudformation-multiple-variables-path-error.png)

You can also manually reproduce the error by in the API Gateway console also.

![](/img/docs/api-gateway-multiple-variables-path-error.png)

So currently, to fix this you must rename `:post_id` to `:id` and use the same sibling variables under the same parent paths.

<a id="prev" class="btn btn-basic" href="{% link _docs/considerations.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/articles.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
