---
title: Jobs
---

A Jets job handles work which is better suited to run in the background - outside of the web request/response cycle. Here's an example:

app/jobs/hard_job.rb:

```ruby
class HardJob < ApplicationJob
  class_timeout 300 # 300s or 5m, current Lambda max is 15m

  rate "10 hours" # every 10 hours
  def dig
    puts "done digging"
  end

  # Cron expression is AWS Cron Format and require 6 fields
  cron "0 */12 * * ? *" # every 12 hours
  def lift
    puts "done lifting"
  end
end
```

In our example, the job `HardJob#dig` will run every 10 hours, and `HardJob#lift` will run every 12 hours.

You can see the lambda functions which correspond to your job functions in the Lambda console:

![The Lambda functions corresponding to the jobs in the AWS Console](/img/docs/demo-lambda-functions-jobs.png)

The `rate` and `cron` methods create CloudWatch Event Rules to handle scheduling. You can see these CloudWatch Event Rules in the CloudWatch console:

![Generated CloudWatch Event Rules for scheduling in the AWS UI](/img/docs/demo-job-cloudwatch-rule.png)

## Running Jobs Explicitly

You can run background jobs explicitly. Example:

```ruby
event = {key1: "value1"}
HardJob.perform_now(:dig, event)
HardJob.perform_later(:lift, event)
```

In the example above, the `perform_now` method executes the job in the **current process**. The `perform_later` function runs the job by invoking the AWS Lambda function associated with it in a **new process**.  It usually runs a few seconds later.

Note, remotely on AWS Lambda, the functions calling the `perform_*` methods need to have the IAM permission to call Lambda. For example, a simple `iam_policy "lambda"` should do it. See [IAM Policies]({% link _docs/managed-iam-policies.md %}) for more info.

## Additional Arguments

Additional arguments are passed to the HardJob with an event hash.

```ruby
event = {key1: "value1"}
HardJob.perform_now(:dig, event)
```

The `event` helper is available in the method.

```ruby
class HardJob
  def dig
    puts "event #{event.inspect}" # event hash is avaialble
  end
end
```

## Cron Expression

The cron expression is in the [AWS Cron format](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html).  The AWS Cron format has six required fields, separated by white space.  This is slightly different from the traditional Linux cron format which has 5 fields.

