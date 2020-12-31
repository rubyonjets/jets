---
title: Config Rules
---

Jets supports creating [AWS Config Rules](https://aws.amazon.com/config/) and associating them with lambda functions.  First, make sure you have a `app/rules/application_rule.rb`:

```ruby
class ApplicationRule < Jets::Rule::Base
end
```

The config rule classes you create will look something like this:

```ruby
class SecurityGroupRule < ApplicationRule
  desc "ensures security groups are hardened"
  scope "AWS::EC2::SecurityGroup"
  def protect
    check = SecurityGroupCheck.new(event, context)
    check.run
  end
end
```

In `app/models`, the SecurityGroupCheck class might look something like this:

```ruby
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
```

## Polymorphic Rules

AWS has provided many starter config rules at [awslabs/aws-config-rules](https://github.com/awslabs/aws-config-rules).  Most of them are written in [python](https://github.com/awslabs/aws-config-rules/tree/master/python). Jets allows you to take these python methods and use them as-is.  For example, you could save these python lambda functions in the `app/workers/rules/protect_rule` folder like so:

```
app/rules/protect_rule/python/ec2_exposed_instance.py
app/rules/protect_rule/python/iam_mfa.py
```

Then in your Rule class, you would use [Jet's polymorphic ability](http://rubyonjets.com/docs/polymorphic-support/):

```ruby
class ProtectRule < ApplicationRule
  scope "AWS::EC2::Instance"
  python :ec2_exposed_instance

  scope "AWS::IAM::User"
  python :iam_mfa
end
```

Jets will create Python lambda functions using the files in the `app/rules/protect_rule/python` folder and associate the Config Rules with these functions.  This saves you time from rewriting the python code.

## Managed Config Rules

[AWS Config Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_use-managed-rules.html) are pre-built rules created by AWS.  For example, there's a [iam-password-policy](https://docs.aws.amazon.com/config/latest/developerguide/iam-password-policy.html) rule that you can set up to show that your AWS account follows a strong password policy. AWS supports a ton of [Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html).  You use AWS managed rules and custom Lambda based rules similarly:

```ruby
class CheckRule < ApplicationRule
  desc "CIS 4.1 - Ensure no security groups allow ingress from 0.0.0.0/0 to port 22"
  scope "AWS::EC2::SecurityGroup"
  managed_rule :incoming_ssh_disabled
end
```

Here's a screenshot example of both types of rules mixed together:

![](/img/docs/aws-config-rules.png)

## Rule Namespace

The config rule classes above inherited from an `ApplicationRule` class.  You can use the `rule_namespace` method to remove the namespace from the config rule names like so:

```ruby
class CheckRule < ApplicationRule
  rule_namespace false
end
```

So this results in the rules looking something like this `check-incoming-ssh-disabled` instead of `demo-dev-check-incoming-ssh-disabled`. The namespace is `demo-dev` in this case.  Note, this will result in you only being able to deploy one instance of the project per `JETS_ENV` since the rule names would collide.

Or you can set your own namespace:

```ruby
class CheckRule < ApplicationRule
  rule_namespace "cis"
end
```

This results in the rules looking something like this `cis-check-incoming-ssh-disabled`.

## Useful Resources

* [AWS::Config::ConfigRule](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-config-configrule.html) CloudFormation reference

