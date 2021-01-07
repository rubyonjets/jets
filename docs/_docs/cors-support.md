---
title: CORS Support
---

Enabling CORS is simple.  You just set `config.cors` in the `config/application.rb` file.  Here's an example:

config/application.rb:

```ruby
Jets.application.configure do
  # ...
  config.cors = true
end
```

A `config.cors = true` will add a response header with `Access-Control-Allow-Origin='*'`.

### Specific Domain

If you would like more specificity for the `Access-Control-Allow-Origin` header then you can set the domain name like so:

```ruby
Jets.application.configure do
  # ...
  config.cors = "*.mydomain.com"
end
```

The example above adds a response header with `Access-Control-Allow-Origin='*.mydomain.com'`.

### Full Customization

If you need full customization of the CORS response headers, you can set `config.cors` as a Hash.

```ruby
Jets.application.configure do
  # ...
  config.cors = {
    "access-control-allow-origin" => "*.mydomain.com",
    "access-control-allow-credentials" => true,
  }
end
```

If you need to control the extra headers added as part pre-flight OPTIONS request you can set `config.cors_preflight`:

```ruby
Jets.application.configure do
  # ...
  config.cors_preflight = {
    "access-control-allow-methods" => "DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT",
    "access-control-allow-headers" => "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent",
  }
  end
```

## Authorization Type

By default, OPTIONS requests will have an `authorization_type = "NONE"`. This allows libraries and frameworks like AWS Amplify to use this HTTP endpoint to send an unsigned preflight request. For some reason if you want to specify authorization_type for the OPTIONS request, you can do this:

```ruby
Jets.application.configure do
  # ...
  config.api.cors_authorization_type = "CUSTOM" # default is "NONE"
end
```

More info: [Routes Authorization]({% link _docs/routing/authorizers/authorization-types.md %})

