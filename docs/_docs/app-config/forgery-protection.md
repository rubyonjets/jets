---
title: Forgery Protection
nav_order: 36
---

By default, csrf forgery protection is enabled in html mode and disabled in api mode when you **generate** the project with [jets new](https://rubyonjets.com/reference/jets-new/). You can override the setting with `default_protect_from_forgery` if you need to change it later.

```ruby
Jets.application.configure do
  config.controllers.default_protect_from_forgery = false
end
```

You can also skip the before_action filter on a per-controller basis.

```ruby
class PostsController < ApplicationController
  skip_forgery_protection
end
```

{% include prev_next.md %}