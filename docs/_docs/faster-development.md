---
title: Faster Development
---

Here are some suggestions to speed up development with Jets and AWS Lambda.

## Cloud9 Recommendation

The best recommendation to speed up your AWS Lambda development workflow is to use [Cloud9](https://aws.amazon.com/cloud9/).  Interestingly, the Lambda Console Editor is a slimmed down version of Cloud9.  You can even use some of the same shortcut keys. So you get the benefit of getting familar with the Lambda Console Editor when you use Cloud9.

Since Cloud9 runs on an EC2 server, a huge benefit is the blazing fast AWS internet pipe.  Here's a comparison:

EC2 Instance Internet Speed:

    $ curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -
    Testing download speed............................................................
    Download: 2399.01 Mbit/s
    Testing upload speed..................................................................
    Upload: 1103.04 Mbit/s
    $

My Fast Home Internet Speed:

    $ curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -
    Testing download speed...................................................................
    Download: 100.50 Mbit/s
    Testing upload speed......................................................................
    Upload: 6.78 Mbit/s
    $

In these cases, there's a 162x upload speed difference. There is no comparison. The upload speed can reduce productivity, even with lazy loading optimizations.  Uploading 100MB on an EC2 internet connection to s3 usually takes less than a second. Also building and downloading new gems is also much faster on EC2. Life is just better with a faster internet connection.

I've actually come to enjoy using Cloud9 and have been pretty happy with it. It has some nice built-in features. It is also nice to have your development environment be available anywhere on any computer in the world with a browser.

## Minimize Gemfile Changes

Jets creates a [Gem Layer]({% link _docs/extras/gem-layer.md %}) to help improve your development workflow speed. The Gem Layer is your application's gem dependencies bundled into a [Lambda Layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html). This is done as part of the [jets deploy](/reference/jets-deploy/) command.

Thanks to the use of Lambda Layers, the `jets deploy` process optimizes things and will only upload a new bundled set of gems to s3 when there are changes. As gems do not change as much as your application code, this optimization speeds up the deploy process significantly. It is not uncommon for gems to add up to 50MB zipped, so only uploading to s3 when required is particularly beneficial on slower internet connections.  On a typical internet connection, it can take 3 minutes to upload 50MB to S3.  The optimization removes this upload time and takes the deploy down to usually about 1 minute after the first deploy.

An additional benefit of the Gem Layer is that it keeps your application code size small. Your app code is usually under the 3MB limit, which is the current maximum package size for the AWS Lambda Console Editor.  This means you can live edit your code, develop, and test without a full deploy.  This is even faster than being able to ssh into the server. Here's a screenshot:

![Screenshot of AWS UI allowing editing of function code](/img/docs/faster-development-live-edit.png)

## CI/CD Pipeline

Another approach for a team is to set up a CI/CD pipeline that will deploy when git commits are pushed.  You may be interested in the [Continuous Integration with CodeBuild docs]({% link _docs/extras/codebuild.md %}).

