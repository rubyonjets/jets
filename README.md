## What is Jets?

Jets is an AWS Lambda Framework that allows you to create serverless applications with ruby.  It includes everything required to build an application and deploy it to AWS Lambda.  It also can be used as a cost-effective worker system. For example, it can be used to write serverless "cron" jobs.

It is key to conceptually understand AWS Lambda and API Gateway to understand Jets.  Jets maps your code to Lambda functions and API Gateway resources.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is the routing layer for Lambda. It is used to route REST URL endpoints to Lambda functions.

## How It Works

With Jets, you focus on your business logic and Jets does the mundane work. You write controllers, workers and functions and Jets automatically uploads this to Lambda and API Gateway for you.

### Jets Controllers

A Jets controller handles a web request and renders a response back to the user.  Here's an example

`app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  def create
    # render returns Lambda Proxy struture for web requests
    render json: {hello: "world"}
  end

  def update
    # event and context are available as a Hash
    render json: event.merge(a: "update"), status: 200
  end
end
```

Jets creates Lambda functions for the public methods in your controller when you run the `jets deploy` command.

### Jets Routing

You hook Lambda functions up to API Gateway URL endpoints.  To route a controller action you use a `config/routes.rb` file:

```ruby
# API Gateway resources are only created if the controller action exists.
get  "posts", to: "posts#index"
get  "posts/:id", to: "posts#show"
post "posts", to: "posts#create"
get  "posts/:id/edit", to: "posts#edit"
put  "posts", to: "posts#update"
delete  "posts", to: "posts#destroy"

# resources :posts # resources macro can be used to all the routes above

any "posts/hot", to: "posts#hot" # GET, POST, PUT, etc request all work
```

Running `jets deploy` adds the routes to API Gateway.

### Project Structure

Here's an overview of a Jets project structure.

File / Directory  | Description
------------- | -------------
app/controllers  | Contains controller code that handles web requests.  The controller code renders API Gateway Lambda Proxy compatible responses.
app/jobs  | Job code for background jobs.  The jobs are performed as Lambda functions, so they are subject to Lambda limits.
app/functions  | Generic function code that look more like the traditional Lambda function handler format.
config/application.yml  | Application wide configurations.  Where you can globally configure things like project_name, env, timeout, memory size.
config/events.yml  | Where you specify events to trigger worker or function code.
config/routes.rb  | Where you set up routes for your application.

## Usage

### Quick Start

You can generate a starter project and deploy to AWS Lambda with:

```sh
jets new proj --starter
cd proj
jets deploy
```

### Scaffolding

You can also use `jets scaffold` to quickly generate basic CRUD code.  Example:

```sh
jets scaffold Post name:string title:string content:text
```

The scaffold creates a migration in `db/migrate` for DynamoDB. You'll need to run migrations to create the DynamoDB table.

```
jets db:migrate
```

Next, deploy the app.

```sh
jets deploy
```

## Install

```sh
gem install jets
```

## Under the hood

Lambda does not yet support ruby. So Jets uses a node shim and a bundled version of ruby to add support.
