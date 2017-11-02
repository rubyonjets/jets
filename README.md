## What is Jets?

Jets is an Serverless Framework that allows you to create applications with ruby on AWS Lambda.  It includes everything required to build an application and deploy it.

It is key to conceptually understand AWS Lambda and API Gateway to understand Jets.  Jets maps your code to Lambda functions and API Gateway resources.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is the routing layer for Lambda. It is used to route REST URL endpoints to Lambda functions.

## How It Works

With Jets, you focus on your business logic and Jets does the mundane work. You write controllers, workers and functions and Jets uploads them to Lambda and API Gateway.

### Jets Controllers

A Jets controller handles a web request and renders a response back to the user.  Here's an example

`app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  def index
    # render returns Lambda Proxy struture for web requests
    render json: {hello: "world"}
  end

  def create
    # render returns Lambda Proxy struture for web requests
    render json: {hello: "world"}
  end
end
```

Jets creates Lambda functions for the public methods in your controller. You deploy the code with:

```sh
jets deploy
```

After deployment, you can test the Lambda functions with the AWS Lambda console or with the jets cli.

### AWS Lambda Console test

[SCREENSHOT OF LAMBDA CONSOLE]

### Jets CLI test

```
jets invoke posts-controller-index '{"test":1}'
jets invoke help # for more info like passing the payload via a file
```

The corresponding aws cli commands are:

```
aws lambda invoke --function-name proj-dev-posts-controller-index --payload '{"test":1}'
aws lambda invoke help
```

### Jets Routing

You connect Lambda functions to API Gateway URL endpoints with a routes file:

`config/routes.rb`:

```ruby
get  "posts", to: "posts#index"
get  "posts/:id", to: "posts#show"
post "posts", to: "posts#create"
get  "posts/:id/edit", to: "posts#edit"
put  "posts", to: "posts#update"
delete  "posts", to: "posts#delete"

resources :comments # expands to all the RESTful routes above

any "posts/hot", to: "posts#hot" # GET, POST, PUT, etc request all work
```

Running `jets deploy` adds the routes to API Gateway.

You can test any of the generated endpoints via curl. Note, you will have to replace the URL endpoint with the one that was created for you:

```sh
$ curl -s https://1oin4qq7ag.execute-api.us-east-1.amazonaws.com/dev/posts
[EXAMPLE RESPONSE]
```

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

You can generate a starter project and deploy it to AWS Lambda with:

```sh
jets new proj
cd proj
ruby db/migrate/posts.rb # to create the posts table
jets deploy
```

This creates and deploys a simple CRUD application to AWS so you can get a feel for how Jets works.

### Testing locally

To improve the speed of development, you can run a local server which mimics the API Gateway routes. So you can test your application code locally and then deploy to AWS Gateway and Lambda when you are ready.

```sh
jets serve
```

## Install

```sh
gem install jets
```

## Under the hood

Lambda does not yet support ruby. So Jets uses a node shim and a bundled version of ruby to add support.

Jets deploys the Lambda and API Gateway resources as a CloudFormation template.

## Contributing

I love pull requests! Happy to answer any questions to help.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
