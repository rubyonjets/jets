---
title: Authorization Scopes
---

Authorization Scopes are support by Cognito authorizers. You can configure the OAuth2 scope in the Gateway API Method Request in two ways.

Note: This interface may be adjusted.

### Controller Wide

You can configure controller-wide the OAuth2 Scope.  Example:

```ruby
class PostsController < ApplicationController
  authorizer "main#my_cognito" # protects all actions in the controller
  authorization_scopes %w[create delete]
end
```

All PostsController actions will be using `create` and `delete` authorization scopes.

### Route Specific

You can also configure the OAuth2 Scope on a per-route basis with the `authorization_scopes ` option:

```ruby
Jets.application.routes.draw do
  get  "posts", to: "posts#index", authorizer: "main#my_cognito", authorization_scopes: %w[create delete]
end
```

