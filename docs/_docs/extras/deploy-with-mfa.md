---
title: Deploying with MFA
---

Jets supports the use of Multi Factor Authentication, MFA.  Jets leverages the [tongueroo/aws-mfa-secure](https://github.com/tongueroo/aws-mfa-secure) gem to achieve this.

## Example

Set up `mfa_serial` for the aws profile section that requires it. Example:

~/.aws/credentials:

    [mfa]
    aws_access_key_id = BKCAXZ6ODJLQ1EXAMPLE
    aws_secret_access_key = ABCDl4hXikfOHTvNqFAnb2Ea62bUuu/eUEXAMPLE
    mfa_serial = arn:aws:iam::112233445566:mfa/MFAUser

Now you'll be able to deploy like usual. Example:

    $ AWS_PROFILE=mfa jets deploy
    Please provide your MFA code: 004578
    Deploying to Lambda demo-dev environment...
    ...
    08:41:16AM UPDATE_COMPLETE AWS::CloudFormation::Stack demo-dev
    Stack success status: UPDATE_COMPLETE
    Time took for stack deployment: 1m 16s.
    Prewarming application.
    API Gateway Endpoint: https://4dwsk84n5h.execute-api.us-west-2.amazonaws.com/dev/
    $

## Another Example

    $ AWS_PROFILE=mfa jets url
    Please provide your MFA code: 364471
    API Gateway Endpoint: https://4dwsk84n5h.execute-api.us-west-2.amazonaws.com/dev
    $ AWS_PROFILE=mfa jets url
    API Gateway Endpoint: https://4dwsk84n5h.execute-api.us-west-2.amazonaws.com/dev
    $

The MFA prompt will only appear once. The session credentials are reused until the session expires per the [tongueroo/aws-mfa-secure](https://github.com/tongueroo/aws-mfa-secure) docs.

