<div align="center">
  <a href="http://rubyonjets.com"><img src="http://rubyonjets.com/img/logos/jets-logo-full.png" /></a>
</div>

Ruby and Lambda splat out a baby and that child's name is [Jets](http://rubyonjets.com/).

![Build Status](https://codebuild.us-west-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiZ08vK2hjOHczQUVoUDhSYnBNNUU4T0gxQWJuOTlLaXpwVGQ1NjJ3NnVDY1dSdFVXQ3d2VXVSQzRFcU1qd1JPMndFZlByRktIcTUrZm5GWlM5dHpjM1ZrPSIsIml2UGFyYW1ldGVyU3BlYyI6Imluc1Qrd25GanhUdHlidjUiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)
[![CircleCI](https://circleci.com/gh/boltops-tools/jets.svg?style=svg)](https://circleci.com/gh/boltops-tools/jets)
[![Gem Version](https://badge.fury.io/rb/jets.svg)](https://badge.fury.io/rb/jets)
[![Support](https://img.shields.io/badge/Support-Help-blue.svg)](http://rubyonjets.com/support/)
[![Gitter Chat](https://badges.gitter.im/boltops-tools/jets.png)](https://gitter.im/boltops-tools/jets)

[![BoltOps Badge](https://img.boltops.com/boltops/badges/boltops-badge.png)](https://www.boltops.com)

**Upgrading**: If you are upgrading Jets, please check on the [Upgrading Notes](http://rubyonjets.com/docs/extras/upgrading/).

## What is Ruby on Jets?

Jets is a Ruby Serverless Framework.  Jets allows you to create serverless applications with a beautiful language: Ruby.  It includes everything required to build an application and deploy it to AWS Lambda.

It is key to understand AWS Lambda and API Gateway to understand Jets conceptually.  Jets maps your code to Lambda functions and API Gateway resources.

* **AWS Lambda** is Functions as a Service. It allows you to upload and run functions without worrying about the underlying infrastructure.
* **API Gateway** is the routing layer for Lambda. It is used to route REST URL endpoints to Lambda functions.

The official documentation is at [Ruby on Jets](http://rubyonjets.com).

Refer to the official docs for more info, but here's a quick intro.

### Jets Functions

Jets supports writing AWS Lambda functions with Ruby. You define them in the `app/functions` folder. A function looks like this:

app/functions/simple.rb:

```ruby
def lambda_handler(event:, context:)
  puts "hello world"
  {hello: "world"}
end
```

Here's the function in the Lambda console:

![Code Example in AWS Lambda console](https://raw.githubusercontent.com/tongueroo/jets/master/docs/img/docs/jets-simple-lambda-function-console.png)


Though simple functions are supported by Jets, they do not add much value as other ways to write Ruby code with Jets. Classes like [Controllers](http://rubyonjets.com/docs/controllers/) and [Jobs](http://rubyonjets.com/docs/jobs/) add many conveniences and are more powerful to use. We’ll cover them next.

### Jets Controllers

A Jets controller handles a web request and renders a response.  Here's an example:

app/controllers/posts_controller.rb:

```ruby
class PostsController < ApplicationController
  def index
    # renders Lambda Proxy structure compatible with API Gateway
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

Helper methods like `params` provide the parameters from the API Gateway event. The `render` method renders a Lambda Proxy structure back that API Gateway understands.

Jets creates Lambda functions for each public method in your controller. Here they are in the Lambda console:

![Lambda Functions for each public method in AWS Console](https://raw.githubusercontent.com/tongueroo/jets/master/docs/img/docs/demo-lambda-functions-controller.png)

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

The `routes.rb` gets translated to API Gateway resources:

![API Gateway Resources generated from routes in AWS console](https://raw.githubusercontent.com/tongueroo/jets/master/docs/img/quick-start/demo-api-gateway.png)

Test your API Gateway endpoints with curl or postman. Note, replace the URL endpoint with the one that is created:

    $ curl -s "https://quabepiu80.execute-api.us-east-1.amazonaws.com/dev/posts" | jq .
    {
      "hello": "world",
      "action": "index"
    }

### Jets Jobs

A Jets job handles asynchronous background jobs performed outside of the web request/response cycle. Here's an example:

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

`HardJob#dig` runs every 10 hours and `HardJob#lift` runs every 12 hours.  The `rate` and `cron` methods created CloudWatch Event Rules. Example:

![CloudWatch Event Rules in AWS Console](https://raw.githubusercontent.com/tongueroo/jets/master/docs/img/docs/demo-job-cloudwatch-rule.png)

### Jets Deployment

You can test your application with a local server that mimics API Gateway: [Jets Local Server](http://rubyonjets.com/docs/local-server/). Once ready, deploying to AWS Lambda is a single command.

    jets deploy

After deployment, you can test the Lambda functions with the AWS Lambda console or the CLI.

### AWS Lambda Console

![Lambda Console](https://s3.amazonaws.com/boltops-demo/images/screenshots/lambda-console-posts-controller-index.png)

### Live Demos

Here are some demos of Jets applications:

* [Quintessential CRUD Jets app](https://demo.rubyonjets.com/)
* [API Demo](https://api.demo.rubyonjets.com/)
* [Jets Afterburner: Easy Rails Support](https://afterburner.demo.rubyonjets.com/)
* [Mega Mode: Jets and Rails Combined](https://mega.demo.rubyonjets.com/)
* [Image Upload with CarrierWave](https://upload.demo.rubyonjets.com/)

Please feel free to add your own example to the [jets-examples](https://github.com/tongueroo/jets-examples) repo.

### Rails Support

[Jets Afterburner Mode](http://rubyonjets.com/docs/rails-support/) provides Rails support with little effort.  This allows you to run a Rails application on AWS Lambda. Also here's a Tutorial Blog Post: [Jets Afterburner: Rails Support](https://blog.boltops.com/2018/12/21/jets-afterburner-serverless-rails-on-aws-lambda-in-5-minutes).

### More Info

For more documentation, check out the official docs: [Ruby on Jets](http://rubyonjets.com/).  Here's a list of useful links:

* [Quick Start](http://rubyonjets.com/quick-start/)
* [Local Jets Server](http://rubyonjets.com/docs/local-server/)
* [REPL Console](http://rubyonjets.com/docs/repl-console/)
* [Project Structure](http://rubyonjets.com/docs/structure/)
* [App Configuration](http://rubyonjets.com/docs/app-config/)
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

## Learning Content

* [Introducing Jets: A Ruby Serverless Framework](https://blog.boltops.com/2018/08/18/introducing-jets-a-ruby-serverless-framework)
* [Official AWS Ruby Support for Jets](https://blog.boltops.com/2018/12/12/official-aws-ruby-support-for-jets-serverless-framework)
* [Build an API with Jets](https://blog.boltops.com/2019/01/13/build-an-api-service-with-jets-ruby-serverless-framework)
* [Serverless Ruby Cron Jobs Tutorial: Route53 Backup](https://blog.boltops.com/2019/01/03/serverless-ruby-cron-jobs-with-jets-route53-backup)
* [Serverless Slack Commands: Fun with AWS Image Recognition](https://blog.boltops.com/2021/02/02/serverless-slack-commands-with-ruby)
* [Jets Afterburner: Rails Support](https://blog.boltops.com/2018/12/21/jets-afterburner-serverless-rails-on-aws-lambda-in-5-minutes)
* [Jets Mega Mode: Jets and Rails](https://blog.boltops.com/2018/11/03/jets-mega-mode-run-rails-on-aws-lambda)
* [Toronto Serverless Presentation](https://blog.boltops.com/2018/09/25/toronto-serverless-presentation-jets-framework-on-aws-lambda)
* [Jets Image Uploads Tutorial with CarrierWave](https://blog.boltops.com/2018/12/13/jets-image-upload-carrierwave-tutorial-binary-support)
* [Jets Tutorial An Introductory CRUD App Part 1](https://blog.boltops.com/2018/09/07/jets-tutorial-crud-app-introduction-part-1)
* [Jets Tutorial Deploy to AWS Lambda Part 2](https://blog.boltops.com/2018/09/08/jets-tutorial-deploy-to-aws-lambda-part-2)
* [Jets Tutorial Debugging Logs Part 3](https://blog.boltops.com/2018/09/09/jets-tutorial-debugging-logs-part-3)
* [Jets Tutorial Background Jobs Part 4](https://blog.boltops.com/2018/09/10/jets-tutorial-background-jobs-part-4)
* [Jets Tutorial IAM Policies Part 5](https://blog.boltops.com/2018/09/11/jets-tutorial-iam-policies-part-5)
* [Jets Tutorial Function Properties Part 6](https://blog.boltops.com/2018/09/12/jets-tutorial-function-properties-part-6)
* [Jets Tutorial Extra Environments Part 7](https://blog.boltops.com/2018/09/13/jets-tutorial-extra-environments-part-7)
* [Jets Tutorial Different Environments Part 8](https://blog.boltops.com/2018/09/26/jets-tutorial-different-environments-part-8)
* [Jets Tutorial Polymorphic Support Part 9](https://blog.boltops.com/2018/09/27/jets-tutorial-polymorphic-support-part-9)
* [Jets Delete Tutorial](https://blog.boltops.com/2018/11/12/jets-tutorial-jets-delete)
