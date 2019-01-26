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

A `config.cors = true` will add a response header with `Access-Control-Allow-Origin='*'`.  If you would like more specificity then you can set the domain name like so:

```ruby
Jets.application.configure do
  # ...
  config.cors = "*.mydomain.com"
end
```

The example above adds a response header with `Access-Control-Allow-Origin='*.mydomain.com'`.

## Authorization Type

By default, OPTIONS requests will have an `authorization_type = "NONE"`. This allows libraries and frameworks like AWS Amplify to use this HTTP endpoint to create, sign, and authorize the sigv4 signature. For some reason if you want to specify authorization_type for the OPTIONS request, you can do this:

```ruby
Jets.application.configure do
  # ...
  config.api.cors_authorization_type = "CUSTOM" # default is "NONE"
end
```

More info: [Routes Authorization]({% link _docs/routing-authorization.md %})

<a id="prev" class="btn btn-basic" href="{% link _docs/routing-custom-domain.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/database-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
