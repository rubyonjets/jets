---
title: Faster Development
---

Development speed with AWS Lambda can be slow due to having to upload the Ruby interpreter and gems as part of the deployment package.  Here are some suggestions:

## Lazy Loading

[Lazy loading]({% link _docs/lazy-loading.md %}) significantly improves your development workflow speed. Lazy loading is enabled by default.  Thanks to lazy loading, the `jets deploy` process optimizes things and will only upload a new bundled set of gems when there are changes. Gems do not change as much as your application code, so this optimization speeds up the deploy process significantly. The bundled Ruby interpreter and gems can add up to 100MB zipped, so only uploading to s3 when required is particularly beneficial on slower internet connections.

## Cloud9 Recommendation

The best recommendation to speed up your AWS Lambda development workflow is to use [Cloud9](https://aws.amazon.com/cloud9/).  By using Cloud9, you get to take advantage of the blazing EC2 internet pipe.  Here's a comparison:

EC2 Instance Internet Speed:

    $ curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -
    Testing download speed............................................................
    Download: 2399.01 Mbit/s
    Testing upload speed..................................................................
    Upload: 1103.04 Mbit/s
    $

Typical Home Internet Speed:

    $ curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -
    Testing download speed...................................................................
    Download: 100.50 Mbit/s
    Testing upload speed......................................................................
    Upload: 6.78 Mbit/s
    $

In these case, there's a 162x upload speed difference. There is no comparison. The upload speed can reduce productivity, even with lazy loading optimizations.  Uploading 100MB on an EC2 internet connection to s3 usually takes less than a second. Also building and downloading new gems is also much faster. Life is just better with a faster internet connection.

I've actually come to enjoy using Cloud9 and have been pretty happy with it. It has some nice built-in features. It is nice to have your development environment be available anywhere on any computer in the world with a browser. It helps in a jam.

## CI/CD Pipeline

Another approach for a team is to set up a CI/CD pipeline that will deploy when git commits are pushed.

<a id="prev" class="btn btn-basic" href="{% link _docs/debug-ruby-errors.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/lazy-loading.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
