---
title: Shared Resources Functions
---

For some Shared Resources you might need create Lambda functions. Instead of writing the Lambda function code inline with the Shared Resource definition, you can define them in `app/shared/functions` and reference them with the `function_code` helper. Here's an example:

```ruby
class Custom
  resource(:fun_time,
    code: function_code("hello.py")
    handler: "hello.lambda_handler",
    runtime: "python2.7"
  )
end
```

You can define the function in the `app/shared/functions` folder:

```python
def lambda_handler:
  print("hello")
```

<a id="prev" class="btn btn-basic" href="{% link _docs/shared-resources-depends-on.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/config-rules.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
