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

## Example skip_before_action

```ruby
class ApplicationController < Jets::Controller::Base
  before_action :authenticate_user_session

  # ...


class PublicDocumentsController < ApplicationController
  # skip the authenticate_user_session for all the methods in the controller
  skip_before_action :authenticate_user_session

  # ...

class PostsController < ApplicationController
  # skip the authenticate_user_session only for the index method in the controller
  skip_before_action :authenticate_user_session, only: [:index]


```

