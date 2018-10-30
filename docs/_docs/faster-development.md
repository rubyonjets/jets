---
title: Faster Development
---

Development speed with AWS Lambda can be slow due to having to upload the Ruby interpreter and gems as part of the deployment package.  Here are some suggestions:

## Lazy Loading

[Lazy loading]({% link _docs/lazy-loading.md %}) significantly improves your development workflow speed. Lazy loading is enabled by default in development.  Thanks to lazy loading, the `jets deploy` process optimizes things and will only upload a new bundled set of gems when there are changes. Gems do not change as much as your application code, so this optimization speeds up the deploy process significantly. The bundled Ruby interpreter and gems can add up to 100MB zipped, so only uploading to s3 when required is particularly beneficial on slower internet connections.  On a typical internet connection, it can take 5 minutes to upload 100MB to S3.  The optimization removes this upload time and takes the deploy down to usually about 1 minute after the first deploy.

An additional benefit of lazy loading is that it keeps your application code size small. With lazy loading, your app code is usually under the 3MB limit, which is the current maximum package size for the AWS Lambda Console Editor.  This means you can live edit your code, develop, and test without a full deploy.  This is even faster than being able to ssh into the server. Here's a screenshot:

![](/img/docs/faster-development-live-edit.png)

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

In these case, there's a 162x upload speed difference. There is no comparison. The upload speed can reduce productivity, even with lazy loading optimizations.  Uploading 100MB on an EC2 internet connection to s3 usually takes less than a second. Also building and downloading new gems is also much faster on EC2. Life is just better with a faster internet connection.

I've actually come to enjoy using Cloud9 and have been pretty happy with it. It has some nice built-in features. It is also nice to have your development environment be available anywhere on any computer in the world with a browser.

## CI/CD Pipeline

Another approach for a team is to set up a CI/CD pipeline that will deploy when git commits are pushed.

<a id="prev" class="btn btn-basic" href="{% link _docs/debug-ruby-errors.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/lazy-loading.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
