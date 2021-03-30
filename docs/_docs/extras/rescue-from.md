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

