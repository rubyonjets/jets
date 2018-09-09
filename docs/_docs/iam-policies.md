---
title: IAM Policies
---

Jets provides several ways to finely control the IAM policies associated with your Lambda functions. Here are the ways and their precedence:

1. Function specific IAM policy: highest precedence
2. Class-wide IAM policy
3. Application-wide IAM policy: lowest precedence

## Function specific IAM policy

```ruby
class PostsController < ApplicationController
  # ...
  iam_policy("s3", "logs")
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
      sid: "MyStmt1",
      action: ["logs:*"],
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

## IAM Policy Definition Styles

You might have noticed that the above `iam_policy` examples take a variety of different parameter styles. Jets allows for different IAM Policy Definition styles for your convenience. The `iam_policy` takes a single parameter or list of parameters.  Jets expands each parameter in the list to Policy Statements in an IAM Policy Document.

Summary of the different expansion styles:

1. Simple Statement: simplest
2. Statement Hash
3. Full Policy Hash: most complex

It is suggested that you start off with the simplest `iam_policy` definition style and use to the more complex styles when needed. Here are examples of each style with their expansion:

### IAM Policy Simple Statement

```ruby
iam_policy("s3", "logs")
```

Expands to:

```yaml
Version: '2012-10-17'
Statement:
- Sid: Stmt1
  Action:
  - s3:*
  Effect: Allow
  Resource: "*"
- Sid: Stmt2
  Action:
  - logs:*
  Effect: Allow
  Resource: "*"
```

The notation with `:*` also works: `iam_policy("s3:*", "logs:*")`.

### IAM Policy Statement Hash

```ruby
class_iam_policy(
  "dynamodb"
  {
    sid: "MyStmt1",
    action: ["logs"],
    effect: "Allow",
    resource: "arn:aws:logs:#{Jets.aws.region}:#{Jets.aws.account}:log-group:#{Jets.config.project_namespace}-*",
  }
)
```

Expands to:

```yaml
Version: '2012-10-17'
Statement:
- Sid: Stmt1
  Action:
  - dynamodb:*
  Effect: Allow
  Resource: "*"
- Sid: Stmt2
  Action:
  - logs:*
  Effect: Allow
  Resource: "arn:aws:logs:us-west-2:1234567890:log-group:demo-dev-*"
```

Note, the resource values are examples.

### IAM Policy Full Policy Hash

```ruby
iam_policy(
  version: "2012-10-17",
  statement: [{
    sid: "MyStmt1",
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
- Sid: MyStmt1
  Action:
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
  - Sid: Stmt1
    Action:
    - s3:*
    Effect: Allow
    Resource: "*"
```

The expanded IAM Policy documents gets included into the CloudFormation template and get associated with the desired Lambda functions. More details on what an raw IAM Policy document looks like can be found at:

* [AWS IAM Policies and Permissions docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html#access_policies-json)
* [CloudFormation IAM Policy reference docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-policy.html)

<a id="prev" class="btn btn-basic" href="{% link _docs/function-properties.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/managed-iam-policies.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
