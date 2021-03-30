---
title: Functions
---

You can write and place simple Lambda functions in the `app/functions` folder. A simple lambda function looks like this:

app/functions/simple.rb:

```ruby
require 'json'
def lambda_handler(event:, context:)
  puts "event: #{JSON.dump(event)}"
  puts "hello world"
  {foo: "bar"}
end
```

The default handler is named `lambda_handler`.  Once deployed, the lambda function shows up in the Lambda console like this:

![Screenshot of the newly generated Lambda function UI in AWS Console](/img/docs/jets-simple-lambda-function-console.png)

You can run the function in the AWS Lambda console and see the results:

![Report of successful execution of the Lambda function](/img/docs/jets-simple-lambda-function-result.png)

Here's an article that covers writing a simple lambda function with Jets: [Jets Simple AWS Lambda Ruby Function](https://blog.boltops.com/2018/10/26/jets-simple-aws-lambda-ruby-function).

Though manually creating simple Lambda functions is possible with Jets, the full power of Jets is in automatically generating the Lambda functions that your API requires. Your API's Lambda functions are defined for you behind the scenes when you use Jets [Controllers]({% link _docs/controllers.md %}) and [Jobs]({% link _docs/jobs.md %}). These classes give you many conveniences methods to make your life easier. We'll cover them next.

