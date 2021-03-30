---
title: Managed IAM Policies
---

Jets also supports [Managed IAM Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html). Managed IAM policies are managed by AWS. This is nice because when AWS releases new features with new API methods, AWS will update the IAM policy accordingly and we don't have to update the policy ourselves.  Managed polices are simple to use with Jets. Here are the ways you can set managed policies and their precedence:

1. Function specific Managed IAM policy: highest precedence
2. Class-wide Managed IAM policy
3. Application-wide Managed IAM policy: lowest precedence

## Function specific Managed IAM policy

```ruby
class PostsController < ApplicationController
  # ...
  managed_iam_policy "AmazonEC2ReadOnlyAccess"
  def show
    render json: {action: "show", id: params[:id]}
  end
end
```

## Class-wide Managed IAM policy

```ruby
class PostsController < ApplicationController
  class_managed_iam_policy(
    "IAMReadOnlyAccess",
    "service-role/AWSConfigRulesExecutionRole"
  )
  # ...
end
```

## Application-wide Managed IAM policy

```ruby
Jets.application.configure do |config|
  config.managed_iam_policy = %w[
    AWSCloudTrailReadOnlyAccess
    IAMReadOnlyAccess
  ]
end
```

## Managed IAM Policies Inheritance

Managed IAM policies defined at lower levels of precedence inherit and include the policies from the higher levels of precedence. This is done so you do not have to duplicate your IAM policies when you only need to add a simple additional permission. For example, if you've configured the application-wide Managed IAM policy to look something like this:

```ruby
Jets.application.configure do |config|
  config.managed_iam_policy = %w[IAMReadOnlyAccess]
end
```

When you add a function specific IAM policy to a method:

```ruby
class PostsController < ApplicationController
  # ...
  managed_iam_policy "AmazonEC2ReadOnlyAccess"
  def show
    render json: {action: "show", id: params[:id]}
  end
end
```

The resulting policy for the method will look something like this:

```yaml
ManagedPolicyArns:
- arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
- arn:aws:iam::aws:policy/IAMReadOnlyAccess
```

So the Managed IAM policies are additive.

## Managed IAM Policies Expansion

The Managed IAM Policies shorthand above ultimately get expanded and included into the CloudFormation templates and get associated with the appropriate Lambda functions.  It ulimately, looks something like this:

```yaml
IamRole:
  Type: AWS::IAM::Role
  Properties:
    ManagedPolicyArns:
    - arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
    - arn:aws:iam::aws:policy/AWSCloudTrailReadOnlyAccess
    - arn:aws:iam::aws:policy/IAMReadOnlyAccess
```

More details on what a raw IAM Policies can be found at:

* [AWS Managed Policies for Job Functions](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html)
* [AWS IAM Policies and Permissions docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html#access_policies-json)
* [CloudFormation IAM Policy reference docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-policy.html)

