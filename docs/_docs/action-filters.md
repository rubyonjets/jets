---
title: Filters
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

<a id="prev" class="btn btn-basic" href="{% link _docs/cors-support.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/polymorphic-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
