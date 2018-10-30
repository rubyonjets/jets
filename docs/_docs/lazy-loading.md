---
title: Lazy Loading
---

Jets supports lazy loading of dependency libraries like RubyGems and the Ruby interpreter.  The [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/limits.html) recommends:

> Each Lambda function receives an additional 512MB of non-persistent disk space in its own /tmp directory. The /tmp directory can be used for loading additional resources like dependency libraries or data sets during function initialization.

Lazy loading happens as a part of the first Lambda request and occurs in the Lambda execution context.  Lazy loading adds an overhead of about 10 seconds. The overhead might seem significant but it only happens on the first request because it runs in the Lambda Execution context. Once the Lambda function is warmed up, additional requests respond in the millisecond range. A Jets request ranges in the 10s of milliseconds and a Mega Mode Rails request ranges in the 100s of milliseconds, usually from 100ms to 300ms.

Additionally, [Prewarming]({% link _docs/prewarming.md %}) helps to avoid the overhead entirely. Prewarming can be tuned for your needs with a few configuration settings.

When lazy loading is turned off, the Ruby dependencies are bundled as part of the Lambda code zip file itself. The cold start overhead is about 2-3 seconds in this case instead.  By default, Jets enables lazy loading in development mode and disables it for production mode.

## Cold Start is Commonly Known

Cold Start problem is commonly known in the AWS Lambda world.  Interestingly, the cold start overhead varies depending on how the Lambda function is configured.

* Lambda Function Memory: The lower the memory you've configured, the slower the CPU you get from Lambda. This can slow down warmup time.  It can take seconds to warm up if you've only configured the 128MB minimum.
* Custom VPC: The network card creation process as part of the bootstraping process can take 10+ seconds.
* Java JVM: Since the JVM is a bit heavy in size it can add seconds to your Lambda function.

These links cover AWS Lambda performance and cold starts a little further:

* [AWS Lambda Ruby Support at Native Speed with Jets](https://blog.boltops.com/2018/09/02/aws-lambda-ruby-support-at-native-speed-with-jets)
* [Jets Native Performance]({% link _docs/native-performance.md %})

## Configuration

To configure lazy loading set the `config.ruby.lazy_load` as part of the [Application Configuration]({% link _docs/app-config.md %}).

config/environments/production.rb:

```ruby
Jets.application.configure do
  config.ruby.lazy_load = true
end
```

Additionally, when `jets deploy` detects that the code size exceeds the AWS Lambda code size limit lazy loading is automatically turned on.

## Advantages of Lazy Loading

There are some huge advantages to lazy loading which is why Jets elects to make it the default setting.

With lazying loading enabled, the actual code size of your Jets project code is usually in the KB range.  This takes the code size down to under the [3 MB](https://docs.aws.amazon.com/lambda/latest/dg/limits.html) limit, which is key. At the smaller code size, you are able to see and edit your Lambda code in the AWS Lambda console code editor live.  It is extremely helpful to debug and test without a full deploy.

Another advantage of lazying loading is that Jets is able to upload the bundled external dependencies like Ruby and Gems separately from the application code itself. This allows Jets to optimize the deploy process and upload the large bundled file only when it changes.  On a slow internet connection this significantly improves your [development speed]({% link _docs/faster-development.md %}) and happiness.

<a id="prev" class="btn btn-basic" href="{% link _docs/faster-development.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/upgrading.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
