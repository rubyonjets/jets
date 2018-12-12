---
title: Functions
---

You can write simple Lambda Ruby functions in the `app/functions` folder. A function looks like this:

app/functions/simple.rb:

```ruby
def lambda_handler(event:, context:)
  pp event
  puts "hello world"
  {foo: "bar"}
end
```

The default handler is named `lambda_handler`.  The lambda function shows up in the Lambda console like this:

![](/img/docs/jets-simple-lambda-function-console.png)

You can run the function in the AWS Lambda console and see the results:

![](/img/docs/jets-simple-lambda-function-result.png)

Here's an article that covers a simple Jets Ruby function: [Jets Simple AWS Lambda Ruby Function](https://blog.boltops.com/2018/10/26/jets-simple-aws-lambda-ruby-function).

Though simple functions are supported by Jets, they do not really add much value as other ways to write Ruby code with Jets. Classes like [Controllers]({% link _docs/controllers.md %}) and [Jobs]({% link _docs/jobs.md %}) add many conveniences and are more powerful to use. We'll cover them next.

<a id="prev" class="btn btn-basic" href="{% link docs.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/controllers.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
