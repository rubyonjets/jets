---
title: Lambda Gems
---

Jets deploy packages up the gems used by your application as part of the zip file and deploys it to AWS Lambda.  Most gems can be use with lambda as-is because they are simply interpreted ruby code. However, some gems are have compiled native extensions. For example, nokogiri is a gem that requires compilation. This presents a problem as your machine's architecture likely does not match the AWS Lambda environment's architecture.

To resolve this Jets uses gems that have been pre-compiled on the [AWS Lambda AMI](https://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html).  The gems are downloaded from the lambdagems website as part of the deploy process.

The Lambda Gems service is currently available for free. Bandwidth and maintaining the service costs money though, so we intend to charge in the future to ensure that the Lambda Gems service is sustainable. We believe Lambda Gems and Jets can be financially successful while being open source. You can also host your own pre-compiled gems and download from your own source urls.

<a id="prev" class="btn btn-basic" href="{% link _docs/how-jets-works.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/next-steps.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
