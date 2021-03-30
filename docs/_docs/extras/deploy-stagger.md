---
title: Deploy Stagger Option
---

## Overview

For large Jets applications, you may see this error during deployment.

> Your request has been throttled by EC2, please make sure you have enough API rate limit. EC2 Error Code: RequestLimitExceeded. EC2 Error Message: Request limit exceeded. (Service: AWSLambdaInternal; Status Code: 400; Error Code: InvalidParameterValueException; Request ID: ea231a7b-cc32-42fe-8584-e78751cbea85)

This error indicates that AWS has wisely established internal rate limits for its Lambda service to call the EC2 service. It means that Lambda is hitting its internal rate limit for calling EC2.

In other words, your Jets application is creating so many Lambda functions in parallel that it is hitting internal AWS Lambda EC2 rate limits.

Other users have [reported](https://forums.aws.amazon.com/thread.jspa?threadID=240384) running into this limit intermittently: [Rate Limit Exceeded?](https://community.rubyonjets.com/t/rate-limit-exceeded/257)  Interestingly, testing a Jets application with over 200 Lambda functions *without* staggering was still not enough to trigger this internal rate limit.

![](/img/docs/extras/deploy-stagger-lambda-functions.png)

So the application has to be quite large to trigger this limit.  This limit may also vary between accounts and region.  There does not seem to be any official guidance from AWS around this limit.

## Stagger Options

Jets supports a "stagger" deploy option to help reduce the rate at which Lambda functions are created in parallel.  It can be turned it on in `config/application.rb`:

```ruby
config.deploy.stagger.enabled = true  # default is false
config.deploy.stagger.batch_size = 10 # default is 10
```

Normally, your Jets code gets translated to CloudFormation nested stacks that get created in parallel.  The stagger options tell CloudFormation to create the stacks serially instead.  Roughly speaking, if your Jets application generates 50 nested stacks, this results in 5 total batches with 10 stacks each. The stagger option intentionally slows down the deploy.

Configuring these settings may help you to stay under the rate limit.  The settings can be tuned for your application.

