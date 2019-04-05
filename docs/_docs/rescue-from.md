---
title: Error Handling
---

Jets provides some error handling capabilities in controllers that can rescue errors that occur during the callbacks or action. This is done with the `rescue_from` method.

## Example rescue_from

```ruby
class PostsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { message: "We could not find your post." }, status: 404
  end

  # ...
end
```

## Example using `with` association

```ruby
class PostsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :missing_post
  
  # ...
  
private
  def missing_post
    render json: { message: "We could not find your post." }, status: 404
  end
end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/action-filters.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/minimal-deploy-iam.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

