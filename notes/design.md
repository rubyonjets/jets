## What is Jets?

Jets is a Ruby Lambda Framework that allows you to create AWS Lambda serverless applications with ruby.  It includes everything required to build a web application and deploy it to AWS Lambda.  It also can be used as a cost-effective worker system. For example, it can be used to write "cron" jobs.

It is key to conceptually understand AWS Lambda and API Gateway to understand Jets.  Jets maps your code to Lambda functions and API Gatway.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is a routing layer for Lambda. You can use it to route url endpoints to your Lambda functions.

## How It Works

With Jets, you focus on your business logic and Jet's does the mechanical work. You write controllers, workers and functions and Jets automatically wire these up to Lambda and API Gateway for you.

### What is a Jets controller?

A Jets controller handles a web request and rendering a response back to the user.  Here's an example

`app/controllers/posts_controller.rb`:

```ruby
class PostsController < Jets::BaseController
  def create
    # event and context is automatically available as a Hash
    # render returns Lambda Proxy struture for web requests
    render json: event, status: 200
  end

  def update
    render json: event.merge(a: "update"), status: 200
  end
end
```

Jets creates up lambda functions for each of the controller public methods above when you run the `jets deploy` command.

### How do I connect API Gateway to the Lambda functions?

You can hook the Lambda functions to url endpoints via API Gateway.  To route an API Gateway endpoint to the controller action, add the following to your routes file:

`config/routes.rb`:

```ruby
# API Gateway resources are only created if the controller action exists.
get  "posts", to: "posts#index"
get  "posts/:id", to: "posts#show"
post "posts", to: "posts#create"
get  "posts/:id/edit", to: "posts#edit"
put  "posts", to: "posts#update"
delete  "posts", to: "posts#destroy"

resources :posts # macro that will creaet all the routes above

any "posts/hot", to: "posts#hot" # GET, POST, PUT, etc request all work
```

Run the `jets deploy` command to add the routes to API Gateway.

### Project Structure

Here's an overview of the project structure.

File / Directory  | Description
------------- | -------------
app/controllers  | controllers code
app/workers  | workers code
app/functions  | functions code
config/project.yml  | project configs
config/events.yml  | events configs
config/routes.rb  | routes


## Usage

### Quick Start

```sh
jets deploy

jets deploy
jets deploy function xxx
jets deploy controller xxx
jets deploy worker xxx
```

### Scaffolding



## Under the hood

Lambda does not yet support ruby. So Jets uses a node shim and a bundled version of ruby to add support.

## Test

Testing controller processing without node shim.

```
jets process controller '{ "we" : "love", "using" : "Lambda" }' '{"test": "1"}' "handlers/controllers/posts.create"
```

Testing the generated node shim handler and the controller processing.

```
cd spec/fixtures/project
jets build # generates the handlers
node handlers/controllers/posts.js
```

Test CloudFormation commands
```sh
aws cloudformation create-stack --stack-name test-stack-$(date +%s) --template-body file://lib/jets/cfn/builder/templates/base-stack.yml --capabilities CAPABILITY_NAMED_IAM