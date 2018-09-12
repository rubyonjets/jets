---
title: FAQ
---

**Q: How do I set cookies from Jets?**

You can set cookies with the `set_header` method in the controller.  Here is an example

```ruby
  def index
    set_header("Set-Cookie", "foo=bar")
    response.set_header("Custom", "MyHeader") # also works to set headers
    response.headers["Custom2"] = "MyHeader" # also works to set headers
  end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/next-steps.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link reference.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
