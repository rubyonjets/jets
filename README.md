Ruby and Lambda splat out a baby, and that child's name is Jets.

## What is Jets?

Jets is a Serverless Framework that allows you to create applications with Ruby on AWS Lambda.  It includes everything required to build an application and deploy it.

It is key to conceptually understand AWS Lambda and API Gateway to understand Jets.  Jets maps your code to Lambda functions and API Gateway resources.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is the routing layer for Lambda. It is used to route REST URL endpoints to Lambda functions.

## How It Works

You focus on your application logic and Jets does the mundane work. You write code called controllers and workers.  Jets turns the code into Lambda functions and uploads them to AWS Lambda and API Gateway.

### Jets Controllers

A Jets controller handles a web request and renders a response.  Here's an example

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

After deployment, you can test the Lambda functions with the AWS Lambda console or CLI.

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
aws lambda invoke --function-name demo-dev-posts_controller-index --payload '{"queryStringParameters":{"test":1}}' outfile.txt
cat outfile.txt | jq '.body | fromjson'
rm outfile.txt
aws lambda invoke help
```

For controllers, the `jets call` method wraps the parameters in the lambda [proxy integration input format structure](http://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format).

### Jets Routing

You connect Lambda functions to API Gateway URL endpoints with a routes file:

`config/routes.rb`:

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

Deploy again to add the routes to API Gateway.

```sh
jets deploy
```

Test your API Gateway endpoints with curl or postman. Note, replace the URL endpoint with the one that was created:

```sh
$ curl -s "https://quabepiu80.execute-api.us-east-1.amazonaws.com/stag/posts" | jq .
{
  "hello": "world",
  "action": "index"
}
```

### Jets Workers

A Jets worker handles background jobs.  It is performed outside of the web request/response cycle. Here's an example:

```
class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    {done: "digging"}
  end
end
```

`HardJob#dig` will be ran every 10 hours.

### Project Structure

Here's an overview of a Jets project structure.

File / Directory  | Description
------------- | -------------
app/controllers  | Contains controller code that handles web requests.  The controller code renders API Gateway Lambda Proxy compatible responses.
app/jobs  | Job code for background jobs.  Jobs are ran as Lambda functions, so they are subject to Lambda limits.
app/functions  | Generic function code that looks more like the traditional Lambda function handler format.
config/application.rb  | Application wide configurations.  Where you can globally configure things like project_name, extra_autoload_paths, function timeout, memory size, etc.
config/routes.rb  | Where you set up routes for your application.

## Usage

### Quick Start

You can generate a starter project and deploy it to AWS Lambda with:

```sh
jets new demo
cd demo
export JETS_ENV=staging
jets dynamodb:generate create_posts # generates migration
jets dynamodb:migrate dynamodb/migrate/20171112194549-create_posts_migration.rb # run migration. replace with your timestamp
jets deploy
```

This creates and deploys a simple CRUD application on AWS so you can get a feel for how Jets works.  Here's a curl command to get posts:

```sh
$ curl -s "https://quabepiu80.execute-api.us-east-1.amazonaws.com/stag/posts" | jq .
{
  "hello": "world",
  "action": "index"
}
```

### Local Test Server

To speed up development, you can run a local server which mimics API Gateway. Test your application code locally and then deploy to AWS when ready.

```sh
jets server
```

You can test your app at [http://localhost:8888](http://localhost:8888).  Here's a curl command to create a post:

```sh
$ curl -s -X POST http://localhost:8888/posts -d '{
  "id": "myid",
  "title": "test title",
  "desc": "test desc"
}' | jq .
{
  "action": "create",
  "post": {
    "id": "myid",
    "title": "test title",
    "desc": "test desc",
    "created_at": "2017-11-04T01:46:03Z",
    "updated_at": "2017-11-04T01:46:03Z"
  }
}
```

You can find examples of all the CRUD actions at [CRUD Curl Jets Tutorial](https://github.com/tongueroo/jets/wiki/CRUD-Curl-Jets-Tutorial).

### Database Support

Jets supports PostgreSQL and DynamoDB.  They can both be used in the same application. If you are using DynamoDB it can be useful to use DynamoDB Local, just like you would use a local SQL server. Here's a [DynamoDB Local Setup Walkthrough](https://github.com/tongueroo/jets/wiki/Dynamodb-Local-Setup-Walkthrough) that takes about 5 minutes.

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

