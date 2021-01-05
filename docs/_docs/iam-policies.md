---
title: IAM Policies
---

Jets provides several ways to finely control the IAM policies associated with your Lambda functions. Here are the ways and their precedence:

1. Function-specific IAM policy: highest precedence
2. Class-wide IAM policy
3. Application-wide IAM policy: lowest precedence

## Function specific IAM policy

```ruby
class PostsController < ApplicationController
  # ...
  iam_policy("s3", "sns")
  def show
    render json: {action: "show", id: params[:id]}
  end
end
```

## Class-wide IAM policy

```ruby
class PostsController < ApplicationController
  class_iam_policy(
    "dynamodb",
    {
      action: ["kinesis:*"],
      effect: "Allow",
      resource: "*",
    }
  )
end
```

## Application-wide IAM policy

```ruby
Jets.application.configure do |config|
  config.iam_policy = ["logs"]
end
```

## IAM Policies Inheritance

IAM policies defined at lower levels of precedence **inherit** and include the policies from the higher levels of precedence. This is done so you do not have to duplicate your IAM policies when you only need to add simple additional permissions. For example, the default application-wide IAM policy looks something like this:

```ruby
[{
  action: ["logs:*"],
  effect: "Allow",
  resource: "arn:aws:logs:REGION:123456789:log-group:/aws/lambda/demo-dev-*",
}]
```

When you add a function specific IAM policy to a method:

```ruby
class PostsController < ApplicationController
  # ...
  iam_policy("s3")
  def show
    render json: {action: "show", id: params[:id]}
  end
end
```

The resulting policy for the method will look something like this:

```ruby
[{
  action: ["logs:*"],
  effect: "Allow",
  resource: "arn:aws:logs:REGION:123456789:log-group:/aws/lambda/demo-dev-*",
},{
  action: ["s3:*"],
  effect: "Allow",
  resource: "*",
}]
```

So the IAM policies are **additive**.

## Application-wide: Override but Keep Default

If you would like to override the default Application-wide IAM policy in `config/application.rb` and still use the Jets default application IAM policy, then set `config.iam_policy`:

```ruby
Jets.application.configure do |config|
  config.iam_policy = [
    {
      action: ["dynamodb:*"],
      effect: "Allow",
      resource: "arn:aws:dynamodb:#{Jets.aws.region}:#{Jets.aws.account}:table/#{Jets.project_namespace}-*",
    }
  ]
end
```

This **adds** to the Jets default application IAM policy. This is useful because the default application IAM policy is dynamically calculated depending on what the resources are being provisioned.  For example, using [Shared Resources]({% link _docs/shared-resources.md %}) will add CloudFormation read permissions.

## Application-wide: Override Entirely

If you wish to override the Jets default application IAM policy entirely, then set `config.default_iam_policy`:

```ruby
Jets.application.configure do |config|
  config.default_iam_policy = [
    {
      action: ["logs:*", "s3:*"],
      effect: "Allow",
      resource: "*",
    }
  ]
end
```

Note, be careful using this advanced technique because it will override the IAM default policy entirely. It could prevent the Jets application from working right because it doesn't have enough permissions. You must make sure that the policy has the right permissions.

## IAM Policy Definition Styles

You might have noticed that the above `iam_policy` examples take a variety of different parameter styles. Jets allows for different IAM Policy Definition styles for your convenience. The `iam_policy` takes a single parameter or list of parameters.  Jets expands each parameter in the list to Policy Statements in an IAM Policy Document.

Summary of the different expansion styles:

1. Simple Statement: simplest
2. Statement Hash
3. Full Policy Hash: most complex

It is suggested that you start off with the simplest `iam_policy` definition style and use to the more complex styles when needed. Here are examples of each style with their expansion:

### IAM Policy Simple Statement

```ruby
iam_policy("s3", "sns")
```

Expands to:

```yaml
Version: '2012-10-17'
Statement:
- Action:
  - s3:*
  Effect: Allow
  Resource: "*"
- Action:
  - sns:*
  Effect: Allow
  Resource: "*"
```

The notation with `:*` also works: `iam_policy("s3:*", "sns:*")`.

### IAM Policy Statement Hash

```ruby
class_iam_policy(
  "dynamodb",
  {
    action: ["kinesis"],
    effect: "Allow",
    resource: "arn:aws:kinesis:#{Jets.aws.region}:#{Jets.aws.account}:stream/name*",
  }
)
```

Expands to:

```yaml
Version: '2012-10-17'
Statement:
- Action:
  - dynamodb:*
  Effect: Allow
  Resource: "*"
- Action:
  - kinesis:*
  Effect: Allow
  Resource: "arn:aws:kinesis:us-west-2:1234567890:stream/name*"
```

Note, the resource values are examples.

### IAM Policy Full Policy Hash

```ruby
iam_policy(
  version: "2012-10-17",
  statement: [{
    action: ["lambda:*"],
    effect: "Allow",
    resource: "*"
  }]
)
```

Expands to:

```yaml
Version: '2012-10-17'
Statement:
- Action:
  - lambda:*
  Effect: Allow
  Resource: "*"
```

## IAM Policy Definition Expansion

What's important to understand is that ultimately, the `iam_policy` definition expands to include an IAM Policy document that looks something like this:

```yaml
PolicyDocument:
  Version: '2012-10-17'
  Statement:
  - Action:
    - s3:*
    Effect: Allow
    Resource: "*"
```

The expanded IAM Policy documents gets included into the CloudFormation template and get associated with the desired Lambda functions. More details on what a raw IAM Policy document looks like can be found at:

* [AWS IAM Policies and Permissions docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html#access_policies-json)
* [CloudFormation IAM Policy reference docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-policy.html)

## Lambda Function vs User Deploy IAM Policies

The IAM Policies docs on this page refer to the IAM policy associated with your **Lambda Execution Role**. These permissions control what AWS resources your Lambda functions have access to.  This is different from the IAM role you use to deploy a Jets application, which is typically your IAM User permissions. If you are looking for the minimal IAM Policy to deploy a Jets application for your IAM user, check out [Minimal Deploy IAM Policy]({% link _docs/extras/minimal-deploy-iam.md %}).

