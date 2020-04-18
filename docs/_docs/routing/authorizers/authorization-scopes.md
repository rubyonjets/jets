---
title: Authorization Scopes
---

You can configure the OAuth2 scope in the Gateway API Method Request in two ways:

### Controller Wide

You can configure controller-wide the OAuth2 Scope.  Example:

```ruby
class PostsController < ApplicationController
    authorization_scopes %w[create delete]
end
```

All PostsController actions will be using `create` and `delete` authorization scopes.

### Route Specific

You can also configure the OAuth2 Scope on a per-route basis with the `authorization_scopes ` option:

```ruby
Jets.application.routes.draw do
  get  "posts", to: "posts#index", authorization_scopes: %w[create delete]
end
```