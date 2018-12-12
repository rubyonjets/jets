---
title: FAQ
---

**Q: How do I set cookies from Jets?**

You can set cookies with the `cookies` helper in the controller. The cookies helper acts like a hash.

```ruby
class PostsController < ApplicationController
  def index
    cookies[:favorite] = "chocolate"
    render json: {message: "yummy cookies set"}
  end
```

**Q: How do I set headers from Jets?**

You can set headers with the `set_header` method in the controller.  Here is an example

```ruby
  def index
    set_header("MyHeader", "foobar")
    response.set_header("Custom", "MyHeader") # also works to set headers
    response.headers["Custom2"] = "MyHeader" # also works to set headers
  end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/articles.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/lambdagems.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
