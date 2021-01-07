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

