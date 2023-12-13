<div align="center">
  <a href="http://rubyonjets.com"><img src="http://rubyonjets.com/img/logos/jets-logo-full.png" /></a>
</div>

[![Gem Version](https://badge.fury.io/rb/jets.svg)](https://badge.fury.io/rb/jets)

[![BoltOps Badge](https://img.boltops.com/boltops/badges/boltops-badge.png)](https://www.boltops.com)

Please **watch/star** this repo to help grow and support the project.

## What is Jets?

[Jets](https://www.rubyonjets.com/) is a Serverless Deployment Service. Jets deploys Serverless infrastructure resources to your AWS account, where you can control the concurrency and scale resources as much as you want.

Jets makes it easy to deploy and run your app on Serverless. It packages up your code and runs it on [AWS Lambda](https://aws.amazon.com/lambda/). Jets can deploy Rails, Sinatra, and any Rack app.

## Quick Start

Add to your project.

Gemfile

```ruby
gem "jets-rails", ">= 1.0"
gem "jets", ">= 6.0"
```

And run

    jets init
    jets deploy

That's it.

## Docs

Official Docs: [docs.rubyonjets.com](https://docs.rubyonjets.com)

Getting Started Learn Guides:

* [Rails](https://docs.rubyonjets.com/docs/learn/rails/)
* [Sinatra](https://docs.rubyonjets.com/docs/learn/sinatra/)
* [Rack](https://docs.rubyonjets.com/docs/learn/rack/)
* [Events](https://docs.rubyonjets.com/docs/learn/events/)
