---
title: Functions
---

You can write and place simple Lambda functions in the `app/functions` folder. A simple lambda function looks like this:

app/functions/simple.rb:

```ruby
def lambda_handler(event:, context:)
  pp event
  puts "hello world"
  {foo: "bar"}
end
```

The default handler is named `lambda_handler`.  Once deployed, the lambda function shows up in the Lambda console like this:

![](/img/docs/jets-simple-lambda-function-console.png)

You can run the function in the AWS Lambda console and see the results:

![](/img/docs/jets-simple-lambda-function-result.png)

Here's an article that covers a writing simple lambda function with Jets: [Jets Simple AWS Lambda Ruby Function](https://blog.boltops.com/2018/10/26/jets-simple-aws-lambda-ruby-function).

Though manually creating simple Lambda functions is possible with Jets, the full power of Jets is in automatically generating the Lambda functions that your API requires. Your API's Lambda functions are defined for you behind the scenes when you use Jets [Controllers]({% link _docs/controllers.md %}) and [Jobs]({% link _docs/jobs.md %}). These classes give you many conveniences methods to make your life easier. We'll cover them next.

<a id="prev" class="btn btn-basic" href="{% link docs.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/controllers.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
