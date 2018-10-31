<div align="center">
  <a href="http://rubyonjets.com"><img src="http://rubyonjets.com/img/logos/jets-logo.png" /></a>
</div>

Ruby and Lambda splat out a baby and that child's name is [Jets](http://rubyonjets.com/).

![Build Status](https://codebuild.us-west-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiUE12K3ljQTFQUjVpRW0reGhGVHVQdkplTHlOdUtENnBya2JhVWVXaFIvTU92MlBtV3hIUE9pb25jWGw0MS9jN2RXMERKRHh5Nzhvd01Za0NyeUs5SCtzPSIsIml2UGFyYW1ldGVyU3BlYyI6IkMybEJFaXdzejJEaHNWVmEiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)
[![CircleCI](https://circleci.com/gh/tongueroo/jets.svg?style=svg)](https://circleci.com/gh/tongueroo/jets)
[![Gem Version](https://badge.fury.io/rb/jets.svg)](https://badge.fury.io/rb/jets)

**Upgrading**: If you are upgrading Jets, please check on the [Upgrading Notes](http://rubyonjets.com/docs/upgrading/).

## What is Jets?

Jets is a Ruby Serverless Framework.  Jets allows you to create serverless applications with a beautiful language: Ruby.  It includes everything required to build an application and deploy it to AWS Lambda.

It is key to understand AWS Lambda and API Gateway to understand Jets conceptually.  Jets maps your code to Lambda functions and API Gateway resources.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is the routing layer for Lambda. It is used to route REST URL endpoints to Lambda functions.

The official documentation is at: [Ruby on Jets](http://rubyonjets.com).

Refer to the official docs for more info, but here's a quick intro.

### Jets Functions

Jets supports writing AWS Lambda functions with Ruby. You define them in the `app/functions` folder. A function looks like this:

app/functions/simple.rb:

```ruby
def handle(event, context)
  puts "hello world"
  {hello: "world"}
end
```

Though simple functions are supported by Jets, aside from the ability to use Ruby, they do not as much value as other ways to write code with Jets.

### Jets Controllers

A Jets controller handles a web request and renders a response.  Here's an example:

app/controllers/posts_controller.rb:

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

### Jets Jobs

A Jets job handles asynchrous background jobs performed outside of the web request/response cycle. Here's an example:

app/jobs/hard_job.rb:

```ruby
class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    puts "done digging"
  end

  cron "0 */12 * * ? *" # every 12 hours
  def lift
    puts "done lifting"
  end
end
```

`HardJob#dig` runs every 10 hours and `HardJob#lift` runs every 12 hours.

### Jets Deployment

You can test your application with a local server that mimics API Gateway: [Jets Local Server](http://rubyonjets.com/docs/local-server/). Once ready, deploying to AWS Lambda is a single command.

	jets deploy

After deployment, you can test the Lambda functions with the AWS Lambda console or the CLI.

### AWS Lambda Console

![Lambda Console](https://s3.amazonaws.com/boltops-demo/images/screenshots/lambda-console-posts-controller-index.png)

### Live Demo

Here's a [Live Demo](https://demo.rubyonjets.com/posts) of the quintessential CRUD Jets app.

### Rails Support

Jets [Mega Mode](http://rubyonjets.com/docs/megamode/) provides Rails support with little effort.  This allows you run a Rails application on AWS Lambda. Refer to the [Rails Support](http://rubyonjets.com/docs/rails-support/) docs for more info.

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
* [Rails Support](http://rubyonjets.com/docs/rails-support/)
* [Tutorials](http://rubyonjets.com/docs/tutorials/)
* [Prewarming](http://rubyonjets.com/docs/prewarming/)
* [Custom Resources](http://rubyonjets.com/docs/associated-resources/)
* [Shared Resources](http://rubyonjets.com/docs/shared-resources/)
* [Installation](http://rubyonjets.com/docs/install/)
* [CLI Reference](http://rubyonjets.com/reference/)
* [Contributing](http://rubyonjets.com/docs/contributing/)
* [Support Jets](http://rubyonjets.com/support-jets/)
* [Example Projects](https://github.com/tongueroo/jets-examples)

## Articles

* [Introducing Jets: A Ruby Serverless Framework](https://blog.boltops.com/2018/08/18/introducing-jets-a-ruby-serverless-framework)
* [AWS Lambda Ruby Support at Native Speed with Jets](https://blog.boltops.com/2018/09/02/aws-lambda-ruby-support-at-native-speed-with-jets)
* [Jets Tutorial An Introductory CRUD App Part 1](https://blog.boltops.com/2018/09/07/jets-tutorial-crud-app-introduction-part-1)
* [Jets Tutorial Deploy to AWS Lambda Part 2](https://blog.boltops.com/2018/09/08/jets-tutorial-deploy-to-aws-lambda-part-2)
* [Jets Tutorial Debugging Logs Part 3](https://blog.boltops.com/2018/09/09/jets-tutorial-debugging-logs-part-3)
* [Jets Tutorial Background Jobs Part 4](https://blog.boltops.com/2018/09/10/jets-tutorial-background-jobs-part-4)
* [Jets Tutorial IAM Policies Part 5](https://blog.boltops.com/2018/09/11/jets-tutorial-iam-policies-part-5)
* [Jets Tutorial Function Properties Part 6](https://blog.boltops.com/2018/09/12/jets-tutorial-function-properties-part-6)
* [Jets Tutorial Extra Environments Part 7](https://blog.boltops.com/2018/09/13/jets-tutorial-extra-environments-part-7)
* [Jets Tutorial Different Environments Part 8](https://blog.boltops.com/2018/09/26/jets-tutorial-different-environments-part-8)
* [Jets Tutorial Polymorphic Support Part 9](https://blog.boltops.com/2018/09/27/jets-tutorial-polymorphic-support-part-9)
