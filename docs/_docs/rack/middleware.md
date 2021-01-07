---
title: Middleware
---

[Jets Controllers]({% link _docs/controllers.md %}) run through a set of Rack middlewares. To can see the full list of middleware with the [jets middleware](http://rubyonjets.com/reference/jets-middleware/) command.

## Configuring Middleware Stack

You can add, swap, and delete middleware from the Jets stack.  Here are some contrived examples:

`config/application.rb`:

```ruby
Jets.application.configure do
  config.middleware.use(new_middleware, args)
  config.middleware.insert_before(existing_middleware, new_middleware, args)
  config.middleware.insert_after(existing_middleware, new_middleware, args)
  config.middleware.use MyMiddleware::Cache, page_cache: false
  config.middleware.swap Rack::Head, MyMiddleware::Head
  config.middleware.delete MyMiddleware
end
```

When each middleware class is initialized, it is passed the Jets.application and the args object.  For example:

```ruby
config.middleware.use MyMiddleware::Cache, page_cache: false
```

Reults in this code:

```ruby
MyMiddleware::Cache.new(app, page_cache: false)
```

