---
title: Filters
nav_order: 64
---

Filters are methods that are run before or after a controller action.

## Example before_action

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :delete]

  # ...

private
  def set_post
    @post = Post.find(params[:id])
  end

end
```

## Example after_action

```ruby
class PostsController < ApplicationController
  after_action :format_post, only: [:show]

  # ...

private
  def format_post
    @post.title.upcase
  end
end
```

{% include prev_next.md %}