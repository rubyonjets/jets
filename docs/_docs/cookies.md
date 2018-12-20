---
title: Cookies
---

You can set cookies with the `cookies` helper.  Example:

```ruby
class PostsController < ApplicationController
  def index
    cookies[:favorite] = "chocolate"
    render json: {message: "yummy cookies set"}
  end

  def show
    cookies.merge! 'foo' => 'bar', 'bar' => 'baz'
    cookies.keep_if { |key, value| key.start_with? 'b' }
    puts "cookies.size: #{cookies.size}"
    render json: {message: "cookies behave like a hash"}
  end
end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/sessions.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/routing-overview.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
