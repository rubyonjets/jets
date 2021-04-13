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

It is recommended that you create an IAM group and associate it with the IAM users that need access to use `jets deploy`.  Here are starter instructions and a policy that you can tailor for your needs. You can follow either the CLI or Console instructions.

1. [CLI Instructions]({% link _docs/extras/minimal-deploy-iam/cli.md %})
2. [Console Instructions]({% link _docs/extras/minimal-deploy-iam/console.md %})

## Lambda Function vs User Deploy IAM Policies

This page refers to your **user** IAM policy used when running `jets deploy`. These are different from the IAM Policies associated with created Lambda functions.  For those iam policies refer to:

* [IAM Policies]({% link _docs/iam-policies.md %})
* [Managed IAM Policies]({% link _docs/managed-iam-policies.md %})

