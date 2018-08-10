---
title: Config Rules
---

Jets supports creating [AWS Config Rules](https://aws.amazon.com/config/) and associating them with lambda functions.  Example:

{% highlight ruby %}
class SecurityGroupRule < Jets::Rule::Base
  desc "ensures security groups are hardened"
  scope "AWS::EC2::SecurityGroup"
  def protect
    check = SecurityGroupCheck.new(event, context)
    check.run
  end
end
{% endhighlight %}

In `app/models`, the SecurityGroupCheck class might look something like this:

{% highlight ruby %}
class SecurityGroupCheck
  APPLICABLE_RESOURCES = ["AWS::EC2::SecurityGroup"]

  def run
    invoking_event = JSON.load(event['invokingEvent'])
    configuration_item = invoking_event['configurationItem']
    rule_parameters = JSON.load(event["ruleParameters"])

    evaluation = evaluate_compliance(configuration_item)

    put_evaluations(
      evaluations: [
        {
          compliance_resource_type: configuration_item['resourceType'],
          compliance_resource_id: configuration_item['resourceId'],
          compliance_type: evaluation['compliance_type'], # required, accepts COMPLIANT, NON_COMPLIANT, NOT_APPLICABLE, INSUFFICIENT_DATA
          annotation: evaluation['annotation'],
          ordering_timestamp: configuration_item['configurationItemCaptureTime'], # required
        },
      ],
      result_token: event['resultToken'], # required
    )
  end
  ...
end
{% endhighlight %}

## Polymorphic Rules

AWS has provided many starter config rules at [awslabs/aws-config-rules](https://github.com/awslabs/aws-config-rules).  Most of them are written in [python](https://github.com/awslabs/aws-config-rules/tree/master/python). One nice thing about Jets is that it will allow you take these python methods and use them as-is.  For exmaple, you could save these python lambda functions in the `app/workers/rules/protect_rule` folder like so:

```
app/rules/protect_rule/python/ec2_exposed_instance.py
app/rules/protect_rule/python/iam_mfa.py
```

Then in your Rule class, you would use Jet's polymorphic ability:

{% highlight ruby %}
class ProtectRule < Jets::Rule::Base
  scope "AWS::EC2::Instance"
  python :ec2_exposed_instance

  scope "AWS::IAM::User"
  python :iam_mfa
end
{% endhighlight %}

Jets will create Python lambda functions using the files in the `app/rules/protect_rule/python` folder and associate the Config Rules with these functions.  This saves you time from rewriting the python code.

<a id="prev" class="btn btn-basic" href="{% link _docs/function-properties.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/polymorphic-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
