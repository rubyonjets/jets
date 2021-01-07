---
title: Forgery Protection
---

By default, csrf forgery protection is enabled in html mode and disabled in api mode. You can override the setting with `default_protect_from_forgery`.

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

