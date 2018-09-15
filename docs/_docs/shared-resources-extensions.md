---
title: Shared Resources Extensions
---

To create your own Shared Resource Extensions, you define a module with the methods in the `app/shared/extensions` folder.  Here's a simple example:

app/shared/extensions/sqs_extension.rb:

```ruby
module SqsExtension
  def sqs_queue(logical_id, props={})
    resource(logical_id, "AWS::SQS::Queue",
      props
    )
    output(logical_id)
  end
end
```

After the module is defined, you can use the method in your [Shared Resource]({% link _docs/shared-resources.md %}) like so:

app/shared/resources/list.rb

```ruby
class List < Jets::Stack
  sqs_queue(:fastpass,
    message_retention_period: 60*24*7
  )
end
```

The code above creates an SQS Queue with a message retention perod of 7 days.  By creating your own resource extensions you can shorten your code dramatically and remove duplication.

Note: The `sqs_queue` is an example and is actually already implemented by Jets. We're using it for demostrative purposes.

<a id="prev" class="btn btn-basic" href="{% link _docs/shared-resources-dsl.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/shared-resources-depends-on.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
