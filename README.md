<div align="center">
  <link href="http://rubyonjets.com"><img src="http://rubyonjets.com/img/logos/jets-logo.png" /></img>
</div>

![Build Status](https://codebuild.us-west-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiUE12K3ljQTFQUjVpRW0reGhGVHVQdkplTHlOdUtENnBya2JhVWVXaFIvTU92MlBtV3hIUE9pb25jWGw0MS9jN2RXMERKRHh5Nzhvd01Za0NyeUs5SCtzPSIsIml2UGFyYW1ldGVyU3BlYyI6IkMybEJFaXdzejJEaHNWVmEiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)
[![CircleCI](https://circleci.com/gh/tongueroo/jets.svg?style=svg)](https://circleci.com/gh/tongueroo/jets)

Ruby and Lambda splat out a baby and that child's name is Jets.

## What is Jets?

Jets is a framework that allows you to create serverless applications with a beautiful language: Ruby.  It includes everything required to build an application and deploy it to on AWS Lambda.

It is key to understand AWS Lambda and API Gateway to understand Jets conceptually.  Jets maps your code to Lambda functions and API Gateway resources.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is the routing layer for Lambda. It is used to route REST URL endpoints to Lambda functions.

The official documentation is at: [Ruby on Jets](http://rubyonjets.com).

Refer to the official docs for more info, but here's a quick intro.

### Jets Controllers

A Jets controller handles a web request and renders a response.  Here's an example:

`app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  def index
    # renders Lambda Proxy structure compatiable with API Gateway
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

Jets creates Lambda functions each the public method in your controller.

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

Test your API Gateway endpoints with curl or postman. Note, replace the URL endpoint with the one that is created:

	$ curl -s "https://quabepiu80.execute-api.us-east-1.amazonaws.com/dev/posts" | jq .
	{
	  "hello": "world",
	  "action": "index"
	}

### Jets Workers

A Jets worker handles background jobs.  It is performed outside of the web request/response cycle. Here's an example:

```ruby
class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    {done: "digging"}
  end

  cron "0 */12 * * ? *" # every 12 hours
  def lift
    {done: "lifting"}
  end
end
```

`HardJob#dig` will be ran every 10 hours and `HardJob#lift` will be ran every 12 hours.

### Jets Deployment

You can test your application with a local server that mimics API Gateway: [Jets Local Server](http://rubyonjets.com/docs/local-server/). Once ready, deploying to AWS Lambda is a single command.

	jets deploy

After deployment, you can test the Lambda functions with the AWS Lambda console or the CLI.

### AWS Lambda Console

![Lambda Console](https://s3.amazonaws.com/boltops-demo/images/screenshots/lambda-console-posts-controller-index.png)

### More Info

For more documentation, check out the official docs: [Ruby on Jets](http://rubyonjets.com/).  Here's a list of useful links:

* [Quick Start](http://rubyonjets.com/quick-start/)
* [Local Jets Server](http://rubyonjets.com/docs/local-server/)
* [REPL Console](http://rubyonjets.com/docs/repl-console/)
* [Jets Call](http://rubyonjets.com/docs/jets-call/)
* [Project Structure](http://rubyonjets.com/project-structure/)
* [App Configuration](http://rubyonjets.com/app-config/)
* [Database Support](http://rubyonjets.com/docs/database-support/)
* [Polymorphic Support](http://rubyonjets.com/docs/polymorphic-support/)
* [Tutorials](http://rubyonjets.com/docs/tutorials/)
* [How Jets Works](http://rubyonjets.com/docs/how-jets-works/)
* [Prewarming](http://rubyonjets.com/docs/prewarming/)
* [Installation](http://rubyonjets.com/docs/install/)
* [CLI Reference](http://rubyonjets.com/reference/)

## Contributing

I love pull requests! Happy to answer questions to help.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

