---
title: Shared Resources Functions
---

For some Shared Resources you might need to create Lambda functions themselves. Instead of writing the Lambda function code inline with the Shared Resource definition, you can define them in `app/shared/functions` and declare them with the `function` helper. Here's an example:

## Ruby Example

app/shared/resources/custom.rb:

```ruby
class Custom
  function(:bob)
end
```

You then define the function in the `app/shared/functions` folder:

app/shared/functions/bob.rb:

```ruby
def handle(event, context)
  puts("hello bob")
end
```

By default, the `function` method creates Ruby lambda functions.  The default Ruby handler is `handle`.

There is also an `ruby_function` alias to the `function` method. They do the same thing.

## Python Example

For Shared Resource Functions, you can use Python just as easily.  Here's an example:

app/shared/resources/custom.rb:

```ruby
class Custom
  python_function(:kevin)
end
```
You then define the function in the `app/shared/functions` folder:

app/shared/functions/kevin.py:

```python
def lambda_handler(event, context):
  print("hello kevin")
```

## Node Example

Here's also a node example:

app/shared/resources/custom.rb:

```ruby
class Custom
  node_function(:stuart)
end
```
app/shared/functions/stuart.js:

```javascript
exports.handler = function(event, context, callback) {
  console.log("hello stuart");
}
```

## General function Form

The methods `ruby_function`, `python_function`, and `node_function` all delegate to the `function` method.  Here's what the general `function` method looks like:

```ruby
class Custom
  function(:kevin,
    handler: "kevin.lambda_handler",
    runtime: "python3.6"
  )
end
```

And the `function` method calls the general Jets::Stack `resource` method.  So the above can also be written like so:

```ruby
class Custom
  resource(:kevin,
    code: {
      s3_bucket: "!Ref S3Bucket",
      s3_key: code_s3_key
    },
    handler: "kevin.lambda_handler",
    runtime: "python3.6"
  )
end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/shared-resources-depends-on.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/rack.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
