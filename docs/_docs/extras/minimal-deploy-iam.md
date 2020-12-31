---
title: Minimal Deploy IAM Policy
---

The IAM user you use to run the `jets deploy` command needs a minimal set of IAM policies in order to deploy a Jets application. Here is a table of the baseline services needed:

Service | Description
--- | ---
API Gateway | To create the API Gateway resources.
CloudFormation | To create the CloudFormation stacks that then creates the most of the AWS resources that Jets creates.
DynamoDB | To look up DynamoDB table stream arn if using [DynamoDB Events]({% link _docs/events/dynamodb.md %}).
Events | To create the CloudWatch Event Rules for jobs.
IAM | To create IAM roles to be associated with the Lambda functions.
Lambda | To prewarm the application upon deployment completion.
Logs | To clean up CloudWatch logs when deleting the application.
Route53 | To create vanity DNS endpoint when using [custom domains]({% link _docs/routing/custom-domain.md %}).
S3 | To upload code to s3.

## Instructions

It is recommended that you create an IAM group and associate it with the IAM users that need access to use `jets deploy`.  Here are starter instructions and a policy that you can tailor for your needs:

### Commands Summary

Here's a summary of the commands:

    aws iam create-group --group-name Jets
    cat << 'EOF' > /tmp/jets-iam-policy.json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "apigateway:*",
                    "cloudformation:*",
                    "dynamodb:*",
                    "events:*",
                    "iam:*",
                    "lambda:*",
                    "logs:*",
                    "route53:*",
                    "s3:*"
                 ],
                "Resource": [
                    "*"
                ]
            }
        ]
    }
    EOF
    aws iam put-group-policy --group-name Jets --policy-name JetsPolicy --policy-document file:///tmp/jets-iam-policy.json
    
If your environment requires a "least privilege" approach, these commands will create a policy that has been reported to work well:

    aws iam create-group --group-name Jets
    export MY_PREFIX=my-cool-prefix
    cat <<EOF > /tmp/jets-iam-policy.json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "cloudformation:CreateStack",
                    "cloudformation:DescribeStackEvents",
                    "cloudformation:DescribeStackResources",
                    "cloudformation:DeleteStack",
                    "cloudformation:UpdateStack"
                ],
                "Resource": [
                    "arn:aws:cloudformation:*:*:stack/${MY_PREFIX}-*",
                    "arn:aws:cloudformation:*:*:stack/${MY_PREFIX}-*/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "iam:PassRole",
                    "iam:GetRole*",
                    "iam:CreateRole",
                    "iam:PutRolePolicy",
                    "iam:DeleteRolePolicy",
                    "iam:DeleteRole"
                ],
                "Resource": [
                    "arn:aws:iam::*:role/${MY_PREFIX}-*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "lambda:PublishLayerVersion",
                    "lambda:DeleteLayerVersion",
                    "lambda:GetFunction",
                    "lambda:CreateFunction",
                    "lambda:GetLayerVersion",
                    "lambda:DeleteFunction",
                    "lambda:UpdateFunctionCode",
                    "lambda:GetFunctionConfiguration",
                    "lambda:UpdateFunctionConfiguration",
                    "lambda:AddPermission",
                    "lambda:RemovePermission",
                    "lambda:InvokeFunction"
                ],
                "Resource": [
                    "arn:aws:lambda:*:*:function:${MY_PREFIX}-*",
                    "arn:aws:lambda:*:*:layer:prod-${MY_PREFIX}-*:*",
                    "arn:aws:lambda:*:*:layer:dev-${MY_PREFIX}-*:*",
                    "arn:aws:lambda:*:*:layer:prod-${MY_PREFIX}-*",
                    "arn:aws:lambda:*:*:layer:dev-${MY_PREFIX}-*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:CreateBucket",
                    "s3:List*",
                    "s3:Describe*",
                    "s3:Put*",
                    "s3:Get*",
                    "s3:Delete*"
                ],
                "Resource": [
                    "arn:aws:s3:::${MY_PREFIX}-*",
                    "arn:aws:s3:::${MY_PREFIX}-*/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "apigateway:*",
                    "cloudformation:DescribeStacks",
                    "logs:DescribeLogGroups"
                ],
                "Resource": [
                    "*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "logs:DeleteLogGroup"
                ],
                "Resource": [
                    "arn:aws:logs:*:*:log-group:/aws/lambda/${MY_PREFIX}-*:*:*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "events:PutRule",
                    "events:DescribeRule",
                    "events:RemoveTargets",
                    "events:DeleteRule",
                    "events:PutTargets"
                ],
                "Resource": [
                    "arn:aws:events:*:*:rule/${MY_PREFIX}-*"
                ]
            }
        ]
    }
    EOF
    aws iam put-group-policy --group-name Jets --policy-name JetsPolicy --policy-document file:///tmp/jets-iam-policy.json

Finally, create a user and add the user to IAM group. Here's an example:

    aws iam create-user --user-name tung
    aws iam add-user-to-group --user-name tung --group-name Jets

## Additional IAM Permissions

The baseline IAM policy above might not include all the permissions required depending on what your Jets application does. For example, if you are using [AWS Config Rules]({% link _docs/extras/config-rules.md %}) or [Custom Resources]({% link _docs/custom-resources.md %}), then you would need to add permissions specific to those resources. This is why an IAM group is recommended.  You simply have to update the group policies.

Here's how you add a managed IAM policy that provides the AWS Config Rule permissions:

    aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSConfigRole --group-name Jets

The IAM Policies for the group looks something like this:

![](/img/docs/minimal-iam-policy.png)

## Lambda Function vs User Deploy IAM Policies

This page refers to your **user** IAM policy used when running `jets deploy`. These are different from the IAM Policies associated with created Lambda functions.  For those iam policies refer to:

* [IAM Policies]({% link _docs/iam-policies.md %})
* [Managed IAM Policies]({% link _docs/managed-iam-policies.md %})

