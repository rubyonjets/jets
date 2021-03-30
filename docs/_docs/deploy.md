---
title: Deploy
---

Once you are ready to deploy your app to Lambda, it's one command to do so:

    jets deploy

After deployment, you can test the Lambda functions with the AWS Lambda console or the CLI.

Lambda Functions:

![](/img/quick-start/demo-lambda-functions.png)

## Minimal Deploy IAM Policy

The IAM user you are using to run the `jets deploy` command needs a minimal set of IAM policies in order to deploy a Jets application. For more info, refer to the [Minimal Deploy IAM Policy]({% link _docs/extras/minimal-deploy-iam.md %}) docs.

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

## Deploying to Different environments:
Deploying to different environments can be achieved with `JETS_ENV`.  
Remember that things like config.domain.hosted_zone_name will need to be unique for your environment(s).
These settings can be specified in config/environments/ to override the global settings.

Example:

    JETS_AGREE=yes JETS_ENV=development bundle exec jets deploy
    JETS_AGREE=yes JETS_ENV=production bundle exec jets deploy

## Deploying to Multiple Regions

Deploying to multiple regions can be achieved with `AWS_REGION`.  Example:

    AWS_REGION=us-east-1 jets deploy
    AWS_REGION=us-west-2 jets deploy

