---
title: Mount Rack Apps
---

Jets Routing supports mounting Rack applications. Example:

```ruby
Jets.application.routes.draw do
  mount GrapeApp, at: 'grape'     # app/racks/grape_app
  mount SinatraApp, at: 'sinatra' # app/racks/sinatra_app
  mount RackApp, at: 'rack'  # app/racks/rack_app
end
```

Many Ruby Web frameworks are Rack compatible like [Sinatra](http://sinatrarb.com/), [Grape](http://www.ruby-grape.org), [Padrino](http://padrinorb.com/), [Hanami](https://hanamirb.org), and [more](https://www.phusionpassenger.com/library/deploy/config_ru.html). The mount ability allows you to run them on serverless with minimal effort.

Note: The Rack apps do not have reside in the `app/racks` folder. They only need to be in a folder that is autoloaded.

## Examples

For an example project demonstrating the use of mount, check out [boltops-tools/jets-routes-mount](https://github.com/boltops-tools/jets-routes-mount).

## Gemfile Dependencies

When you mount a Rack app, you must also remember to add the its dependencies to your Gemfile. For example, if you are mounting a Sinatra app, then add the sinatra gem to `Gemfile`:

```ruby
gem "sintara"
```

## Mount at Root

To mount at the homepage root use an empty string for the `at` option. Example:

```ruby
Jets.application.routes.draw do
  mount GrapeApp, at: '' # app/racks/grape_app
end
```

## Custom Domain

When you deploy your application, API Gateway will add the stage name to the path.  Here's an example with the `dev` stage: https://xbrp9dekhc.execute-api.us-west-2.amazonaws.com/dev

For Jets apps, the url helpers will add the stage name as necessary. Other frameworks do not have url helpers that account for API Gateway stage names. Applications usually referred to links by their document root url. For example, `<a href=/posts>Posts</a>`.  So you'll end up with this:

    https://xbrp9dekhc.execute-api.us-west-2.amazonaws.com/posts # doesnt work

Instead of:

    https://xbrp9dekhc.execute-api.us-west-2.amazonaws.com/dev/posts # works

A quick way to fix this is use a [Custom Domain]({% link _docs/routing/custom-domain.md %}).  Custom domain urls not have a stage name appended and will look something like this:

    https://demo-dev.example.com/posts # works

## General Recommendation

For lightweight frameworks like Sinatra and Grape mounting them is recommended. For heavier frameworks like Rails, mounting is not currently recommended. See: [Mounting Rails Apps]({% link _docs/rails/mount.md %}).

