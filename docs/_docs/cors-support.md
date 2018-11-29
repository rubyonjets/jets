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

A `config.cors = true` will add a response header with `Access-Control-AllowOrigin='*'`.  If you would like more specificity then you can set the domain name like so:

```ruby
Jets.application.configure do
  # ...
  config.cors = "*.mydomain.com"
end
```

The example above adds a response header with `Access-Control-AllowOrigin='*.mydomain.com'`.

<a id="prev" class="btn btn-basic" href="{% link _docs/routing-custom-domain.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/database-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
