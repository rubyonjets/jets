---
title: Native Performance
---

AWS Lambda does not yet officially support Ruby. There's an online petition to encourage AWS to add Ruby support for Lambda: [We want FaaS for Ruby!](https://www.serverless-ruby.org/) Rumors suggest that AWS is working on it.

To run Ruby on AWS Lambda today, we can resort to using a shim. This was detailed in the AWS Blog post [Scripting Languages for AWS Lambda: Running PHP, Ruby, and Go
](https://aws.amazon.com/blogs/compute/scripting-languages-for-aws-lambda-running-php-ruby-and-go/).  Essentially, you write a lambda function in a natively supported Lambda language like node and then have that function shell out to Ruby. Additionally, the Ruby interpreter itself is packaged with the Lambda code zip file.

One of the issues with shelling out to a Ruby interpreter is the overhead in doing so is pretty high. If your Lambda function is allocated only 128MB the overhead is a nasty 5+ seconds. Vlad Holubiev discovered that if you allocate more memory to your Lambda functions, then the functions get faster CPU hardware: [My Accidental 3–5x Speed Increase of AWS Lambda Functions
](https://serverless.zone/my-accidental-3-5x-speed-increase-of-aws-lambda-functions-6d95351197f). Chris Munns, Senior Developer Advocate for Serverless at AWS, confirmed this and stated that
Lambda [Functions with more than 1.8GB of memory are multi core](https://www.jeremydaly.com/15-key-takeaways-from-the-serverless-talk-at-aws-startup-day/).  Even so, running lambda function with a max of 3008MB results in a one second overhead penalty, about the penalty of a [cold start](https://theburningmonk.com/2018/01/im-afraid-youre-thinking-about-aws-lambda-cold-starts-all-wrong/).

To get around this, Jets uses a shim that loads the ruby interpreter into [Lambda Function Execution Context](https://docs.aws.amazon.com/lambda/latest/dg/running-lambda-code.html) memory. Subsequent lambda function executions do not pay the overhead costs repeatedly. Additionally, Jets automatically prewarms your application: [Prewarming]({% link _docs/prewarming.md %}). This makes Jets support of Ruby as fast as native languages supported by AWS Lambda.  Here's an example of the performance:

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

In the case above, the ruby function happened to be faster than the python function. Generally, it's a tie. This article covers native perforamnce further: [AWS Lambda Ruby Support at Native Speed with Jets](https://blog.boltops.com/2018/09/02/aws-lambda-ruby-support-at-native-speed-with-jets).

<a id="prev" class="btn btn-basic" href="{% link _docs/crud-json-activerecord.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/lambdagems.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
