---
title: Filtering Params
---

By default, all params and event payload will be logged to CloudWatch in every request. You can override this setting with `filtered_parameters` to
filter out sensitive information and mask it as FILTERED within the request log.

```ruby
Jets.application.configure do
  config.controllers.filtered_parameters += [:password, :credit_card]
end
```

You can also use dot notation for nested parameters

```ruby
class PostsController < ApplicationController
  config.controllers.filtered_parameters += ["user.password"]
end
```

