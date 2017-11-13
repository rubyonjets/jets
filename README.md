Ruby and Lambda splat out a baby, and that child's name is Jets.

## What is Jets?

Jets is a Serverless Framework that allows you to create applications with Ruby on AWS Lambda.  It includes everything required to build an application and deploy it.

It is key to conceptually understand AWS Lambda and API Gateway to understand Jets.  Jets maps your code to Lambda functions and API Gateway resources.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is the routing layer for Lambda. It is used to route REST URL endpoints to Lambda functions.

## How It Works

You focus on your application logic and Jets does the mundane work. You write code called controllers and workers.  Jets turns them into Lambda funcitons and uploads them to AWS Lambda and API Gateway.

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
    id = params[:id] # params available
    # puts goes to the lambda logs
    puts event # raw lambda event available
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

![Lambda Console](https://s3.amazonaws.com/boltops-demo/images/screenshots/lambda-console-posts-controller-index.png)

### CLI test

You can use `jets call` to test via the the CLI:

```
$ jets call posts-controller-index '{"test":1}' | jq '.body | fromjson'
{
  "hello": "world",
  "action": "index"
}
$ jets call help # for more info like passing the payload via a file
```

The corresponding `aws lambda` CLI commands are:

```
aws lambda invoke --function-name demo-dev-posts_controller-index --payload '{"test":1}' outfile.txt
cat outfile.txt | jq '.body | fromjson'
rm outfile.txt
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

Deploying again to add the routes to API Gateway.

```sh
jets deploy
```

Test your of the API Gateway endpoints with curl or postman. Note, replace the URL endpoint with the one that was created:

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
export JETS_ENV=staging
jets dynamodb generate create_posts # generates migration
jets dynamodb migrate dynamodb/migrate/*_create_posts.rb # run migration
jets deploy
```

This creates and deploys a simple CRUD application on AWS so you can get a feel for how Jets works.  Here's curl command to create a post:

```sh
curl -sv http://endpoint/stag/posts | jq .
```

### Local Test Server

To improve the speed of development, you can run a local server which mimics API Gateway. So you can test your application code locally and then deploy to AWS when you are ready.

```sh
jets server
```

You can test your app at [http://localhost:8888](http://localhost:8888).  Example:

```
curl -sv -X POST http://localhost:8888/posts -d @payloads/create.json
```

Examples of calling all the CRUD actions is available on the [CRUD Curl with Jets]() tutorial.

### DynamoDB Local

Using DynamoDB Local is useful if you are using DynamoDB. Just like develop with a local MySQL server, you can do the same with DynamoDB.  Here's a [DynamoDB Local Setup Walkthrough](https://github.com/tongueroo/jets/wiki/Dynamodb-Local-Setup-Walkthrough) which takes about 5 minutes.

### REPL Console

You can test things out in a REPL console:

```sh
jets console
> Post.table_name
```

## Install

```sh
gem install jets
```

## Under the hood

Lambda does not yet support Ruby. So Jets uses a node shim and a bundled version of Ruby to add support.

## Contributing

I love pull requests! Happy to answer questions to help.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
