---
title: Deploy
---

Once you are ready to deploy your app to Lambda, it's one command to do so:

    jets deploy

After deployment, you can test the Lambda functions with the AWS Lambda console or the CLI.

Lambda Functions:

![](/img/quick-start/demo-lambda-functions.png)

## Minimal Deploy IAM Policy

The IAM user you are using to run the `jets deploy` command needs a minimal set of IAM policies in order to deploy a Jets application. For more info, refer to the [Minimal Deploy IAM Policy]({% link _docs/minimal-deploy-iam.md %}) docs.

## Deploy to Different AWS Accounts

To deploy to different AWS accounts, use different AWS profiles. To set up the different AWS profiles refer to the AWS docs: [Multiple AWS Profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html). Here's an example for your convenience:

~/.aws/credentials:

    [default]
    aws_access_key_id=AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

    [account2]
    aws_access_key_id=AKIAI44QH8DHBEXAMPLE
    aws_secret_access_key=je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY

~/.aws/config:

    [default]
    region=us-west-2
    output=json

    [profile account2]
    region=us-east-1
    output=json

To deploy to different accounts:

    jets deploy
    AWS_PROFILE=account2 jets deploy

<a id="prev" class="btn btn-basic" href="{% link _docs/repl-console.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/jets-call.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
