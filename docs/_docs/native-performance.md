---
title: Native Performance
---

**Update**: Jets has been switched over to [AWS Official Ruby Support](https://aws.amazon.com/blogs/compute/announcing-ruby-support-for-aws-lambda/)!  AWS Official Ruby Support was announced at [AWS re:Invent 2018 on Nov 29](https://twitter.com/tongueroo/status/1068199997097750528)! This doc no longer applies and is only here for posterity.

Jets used to use a shim to run Ruby. This was detailed in the AWS Blog post [Scripting Languages for AWS Lambda: Running PHP, Ruby, and Go
](https://aws.amazon.com/blogs/compute/scripting-languages-for-aws-lambda-running-php-ruby-and-go/).  Essentially, you write a lambda function in a natively supported Lambda language like node and then have that function shell out to Ruby. Additionally, the Ruby interpreter itself is packaged with the Lambda code zip file.

One of the issues with shelling out to a Ruby interpreter is the overhead in doing so is pretty high. If your Lambda function is allocated only 128MB the overhead is a nasty 5+ seconds. Vlad Holubiev discovered that if you allocate more memory to your Lambda functions, then the functions get faster CPU hardware: [My Accidental 3–5x Speed Increase of AWS Lambda Functions
](https://serverless.zone/my-accidental-3-5x-speed-increase-of-aws-lambda-functions-6d95351197f). Chris Munns, Senior Developer Advocate for Serverless at AWS, confirmed this and stated that
Lambda [Functions with more than 1.8GB of memory are multi core](https://www.jeremydaly.com/15-key-takeaways-from-the-serverless-talk-at-aws-startup-day/).  Even so, running lambda function with a max of 3008MB results in a one second overhead penalty, about the penalty of a [cold start](https://theburningmonk.com/2018/01/im-afraid-youre-thinking-about-aws-lambda-cold-starts-all-wrong/).

To get around this, Jets used a shim that loads the Ruby interpreter into [Lambda Function Execution Context](https://docs.aws.amazon.com/lambda/latest/dg/running-lambda-code.html) memory. Subsequent lambda function executions do not pay the overhead costs repeatedly. Additionally, Jets automatically prewarms your application: [Prewarming]({% link _docs/prewarming.md %}). This makes Jets support of Ruby as fast as native languages supported by AWS Lambda.  Here's an example of the performance:

Ruby function speed:

    time curl -so /dev/null https://1192eablz8.execute-api.us-west-2.amazonaws.com/dev/ruby_example
    real    0m0.164s
    user    0m0.039s
    sys     0m0.063s

Python function speed:

    time curl -so /dev/null https://1192eablz8.execute-api.us-west-2.amazonaws.com/dev/python_example
    real    0m0.178s
    user    0m0.047s
    sys     0m0.054s

In the case above, the Ruby function happened to be faster than the Python function. Generally, it's a tie. This article covers native perforamnce further: [AWS Lambda Ruby Support at Native Speed with Jets](https://blog.boltops.com/2018/09/02/aws-lambda-ruby-support-at-native-speed-with-jets).