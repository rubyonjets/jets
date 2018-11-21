---
title: Routing
---

You connect Lambda functions to API Gateway URL endpoints with a routes file:

config/routes.rb:

```ruby
Jets.application.routes.draw do
  get  "posts", to: "posts#index"
  get  "posts/new", to: "posts#new"
  get  "posts/:id", to: "posts#show"
  post "posts", to: "posts#create"
  get  "posts/:id/edit", to: "posts#edit"
  put  "posts", to: "posts#update"
  delete  "posts", to: "posts#delete"

  resources :comments # expands to the RESTful routes above

  any "posts/hot", to: "posts#hot" # GET, POST, PUT, etc request all work
end
```

Test your API Gateway endpoints with curl or postman. Note, replace the URL endpoint with the one that is created:

    $ curl -s "https://quabepiu80.execute-api.us-east-1.amazonaws.com/dev/posts" | jq .
    {
      "hello": "world",
      "action": "index"
    }

You can check the routes on the API Gateway console:

![](/img/quick-start/demo-api-gateway.png)

##Authorization
By default, each route specified will not require any authorization in order to call it.
You can choose to enable authorization on a per-route basis:
```ruby
Jets.application.routes.draw do
  get  "posts", to: "posts#index", authorization_type: "AWS_IAM"
end
```
This will require a caller to authenticate using IAM before being able to access the endpoint.
The complete list of authorization types is available in the [AWS API Gateway docs](https://docs.aws.amazon.com/apigateway/api-reference/resource/method/#authorizationType).

## jets routes

You can also check the routes with the `jets routes` cli command. Here's an example:

    $ jets routes
    +--------+----------------+--------------------+
    |  Verb  |      Path      | Controller#action  |
    +--------+----------------+--------------------+
    | GET    | posts          | posts#index        |
    | GET    | posts/new      | posts#new          |
    | GET    | posts/:id      | posts#show         |
    | POST   | posts          | posts#create       |
    | GET    | posts/:id/edit | posts#edit         |
    | PUT    | posts/:id      | posts#update       |
    | DELETE | posts/:id      | posts#delete       |
    | ANY    | *catchall      | jets/public#show   |
    +--------+----------------+--------------------+
    $


<a id="prev" class="btn btn-basic" href="{% link _docs/controllers.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/jobs.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
