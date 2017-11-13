Ruby and Lambda splat out a baby, and that child's name is Jets.

## What is Jets?

Jets is a Serverless Framework that allows you to create applications with Ruby on AWS Lambda.  It includes everything required to build an application and deploy it.

It is key to conceptually understand AWS Lambda and API Gateway to understand Jets.  Jets maps your code to Lambda functions and API Gateway resources.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is the routing layer for Lambda. It is used to route REST URL endpoints to Lambda functions.

## How It Works

You focus on your application logic and Jets does the mundane work. You write application code called controllers and workers and Jets uploads them to Lambda and API Gateway.

### Jets Controllers

A Jets controller handles a web request and renders a response back.  Here's an example

`app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  def index
    # render returns Lambda Proxy structure for web requests
    render json: {hello: "world", action: "index"}
  end

  def show
    id = params[:id] # params are available
    puts event # raw lambda even also are available
               # puts goes to the lambda logs
    render json: {action: "show", id: id}
  end
end
```

Jets creates Lambda functions for the public methods in your controller. You deploy the code with:

```sh
jets deploy
```

After deploymment, you can test the Lambda functions with the AWS Lambda console or CLI.

### AWS Lambda Console test

[SCREENSHOT OF LAMBDA CONSOLE]

### CLI test

A `jets call` command makes testing with the CLI more convenient:

```
jets call posts-controller-index '{"test":1}'
jets call help # for more info like passing the payload via a file
```

The corresponding `aws lambda` CLI commands is:

```
aws lambda invoke --function-name demo-dev-posts_controller-index --payload '{"test":1}' outfile.txt ; cat outfile.txt ; rm outfile.txt
aws lambda invoke help
```

### Jets Routing

You connect Lambda functions to API Gateway URL endpoints with a routes file:

`config/routes.rb`:

```ruby
get  "posts", to: "posts#index"
get  "posts/new", to: "posts#new"
get  "posts/:id", to: "posts#show"
post "posts", to: "posts#create"
get  "posts/:id/edit", to: "posts#edit"
put  "posts", to: "posts#update"
delete  "posts", to: "posts#delete"

resources :comments # expands to the RESTful routes above

any "posts/hot", to: "posts#hot" # GET, POST, PUT, etc request all work
```

Deploying again adds the routes to API Gateway.

```sh
jets deploy
```

You can test any of the API Gateway endpoints. Note, replace the URL endpoint with the one that was created for you:

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
jets new demo
cd demo
export JETS_ENV=production
jets dynamodb generate create_posts # generates migration
jets dynamodb migrate dynamodb/migrate/*_create_posts.rb # run migration
jets deploy
```

This creates and deploys a simple CRUD application to AWS so you can get a feel for how Jets works.

### Local Test Server

To improve the speed of development, you can run a local server which mimics API Gateway. So you can test your application code locally and then deploy to AWS when you are ready.

```sh
jets server
```

You can test your app at [http://localhost:8888](http://localhost:8888).  Example:

```
curl -sv http://localhost:8888/posts
```

### DynamoDB Local

Just like you developer with a local MySQL install, you can with a local DynamoDB install.  This is especially useful if you when you are running unit tests, so you don't get charged for DynamoDB for your tests.  Here's [DynamoDB Local Setup Walkthrough](https://github.com/tongueroo/jets/wiki/Dynamodb-Local-Setup-Walkthrough).  It takes about 5 minutes.


### REPL Console

You can test things out in a REPL console also:

```sh
jets console
> Post.table_name
```

## Install

```sh
gem install jets
```

## Under the hood

Lambda does not yet support ruby. So Jets uses a node shim and a bundled version of ruby to add support.

Jets deploys the Lambda and API Gateway resources as a CloudFormation stack.

## Contributing

I love pull requests! Happy to answer questions to help.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
