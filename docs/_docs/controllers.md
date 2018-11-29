---
title: Controllers
---

A Jets controller handles a web request and renders a response. Here's an example:

app/controllers/posts_controller.rb:

```ruby
class PostsController < ApplicationController
  def index
    # renders Lambda Proxy structure compatiable with API Gateway
    render json: {hello: "world", action: "index"}
  end

  def show
    id = params[:id] # params available
    # puts goes to the lambda logs
    puts event # raw lambda event available
    render json: {action: "show", id: id}
  end
end
```

Helper methods like `params` provide the parameters from the API Gateway event.  The `render` method renders a Lambda Proxy structure back that API Gateway understands.

For each public method in your controller, Jets creates a Lambda function:

![](/img/docs/demo-lambda-functions-controller.png)

<a id="prev" class="btn btn-basic" href="{% link docs.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/routing.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
