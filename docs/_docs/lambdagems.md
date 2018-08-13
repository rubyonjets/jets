---
title: Lambda Gems
---

Jets deploy packages up the gems used by your application as part of the zip file and deploys it to AWS Lambda.  Most gems can be used with Lambda as-is because they are pure Ruby code. However, some gems are have compiled native extensions. For example, nokogiri is a gem that uses compiled native extensions. This presents a problem as your machine's architecture likely does not match the AWS Lambda environment's architecture.  The same compiled gems from your machine will not work on Lambda.

To resolve this Jets detects which gems contain compiled dependencies and uses  gems that have been pre-compiled on the [AWS Lambda AMI](https://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html).  These pre-compiled gems are downloaded from the lambdagems site as part of the deploy process.

The Lambda Gems service is currently available for free. Bandwidth and maintaining the service requires money, time, and effort. Without proper financial backing the service will not be sustainable, so we intend to charge in the future. We believe Lambda Gems and Jets can be financially successful while being open source. You can also host your own pre-compiled gems and download from your own source url.

```ruby
Jets.application.configure do
  # checks the list in order
  config.lambdagems.sources = [
    "https://lambdagems.com",
    "https://yoursource.com",
  ]
  # ...
end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/how-jets-works.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/next-steps.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
