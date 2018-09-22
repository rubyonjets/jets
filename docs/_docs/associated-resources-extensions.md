---
title: Associated Resources Extensions
---

You can define your own custom associated resoures methods. This helps makes for shorter and cleaner code. Remember that methods like `cron` and `rate` are just convenience methods that ultimately call the `resource` method. You can extend Jets with your own custom convenience methods.

## Example Extension

To define a custom extension, you create a module in the `app/extensions` folder.  Here's an example:

app/extensions/iot_extension.rb:

```ruby
module IotExtension
  def thermostat_rule(logical_id, props={})
    defaults = {
      topic_rule_payload: {
        sql: "select * from TemperatureTopic where temperature > 60"
      },
      actions: [
        lambda: { function_arn: "!Ref {namespace}LambdaFunction" }
      ]
    }
    props = defaults.merge(props)
    resource(logical_id, "AWS::Iot::TopicRule", props)
  end
end
```

After the module is defined, you can use the newly created convienence method like so:

```ruby
class TemperatureJob < ApplicationJob
  thermostat_rule(:room)
  def record
    # custom business logic
  end
end
```

The code above creates an `AWS::Iot::TopicRule` and runs the `record` Lambda function for incoming IoT thermostat data.  You can add your own custom business logic to handle the data accordingly.

<a id="prev" class="btn btn-basic" href="{% link _docs/associated-resources.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/shared-resources.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
