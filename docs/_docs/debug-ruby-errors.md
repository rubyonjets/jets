---
title: Debugging Ruby Errors
---

In [How Jets Works]({% link _docs/native-performance.md %}), we cover that  AWS Lambda does not currently support Ruby natively.  Jets adds Ruby Support by using a node shim. You might think that this means you will need to debug node errors. But this is not the case at all. Jets surfaces the Ruby stack trace error up through the node shim all the way to the Lambda Console.

## Example

Here's an example of Ruby code throwing an intentional error:

```ruby
class PostsController < ApplicationController
  # ...
  def ruby_example_error
    INTENTIONAL_RUBY_ERROR
    render json: {message: "hello from ruby #{RUBY_VERSION}"}
  end
end
```

Here's what the stack trace appears like in the Lambda Console.

![](/img/docs/lambda-console-ruby-error.png)

You keep your mental context in Ruby land the entire time 😁

<a id="prev" class="btn btn-basic" href="{% link _docs/blue-green-deployment.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/faster-development.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
