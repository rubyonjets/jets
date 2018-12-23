Jets translates your `routes.rb` file into API Gateway resources, and connects them to your Lambda functions:

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

You can check your routes in the API Gateway console:

![](/img/quick-start/demo-api-gateway.png)

You can get your API Gateway endpoints from the API Gateway console, and test them with curl or postman. Example:

    $ curl -s "https://quabepiu80.execute-api.us-east-1.amazonaws.com/dev/posts" | jq .
    {
      "hello": "world",
      "action": "index"
    }

## jets routes

Run the `jets routes` cli command to get a list of your routes.

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
