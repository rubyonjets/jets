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

Jets evaluates the `routes.rb` file and creates corresponding API Gateway resources.  You can check the routes on the API Gateway console:

![](/img/quick-start/demo-api-gateway.png)

Test your API Gateway endpoints with curl or postman. Note, replace the URL endpoint with the one that is created:

    $ curl -s "https://quabepiu80.execute-api.us-east-1.amazonaws.com/dev/posts" | jq .
    {
      "hello": "world",
      "action": "index"
    }

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
