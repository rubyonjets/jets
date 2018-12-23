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

  cron "0 */12 * * ? *" # every 12 hours
  def lift
    puts "done lifting"
  end
end
```

In our exmple, the job `HardJob#dig` will run every 10 hours, and `HardJob#lift` will run every 12 hours.

You can see the lambda functions which correspond to your job functions in the Lambda console:

![](/img/docs/demo-lambda-functions-jobs.png)

The `rate` and `cron` methods create CloudWatch Event Rules to handle scheduling. You can see these CloudWatch Event Rules in the CloudWatch console:

![](/img/docs/demo-job-cloudwatch-rule.png)

## Running Jobs Explicitly

You can run background jobs explicitly. Example:

```ruby
event = {key1: "value1"}
HardJob.perform_now(:dig, event)
HardJob.perform_later(:lift, event)
```

In the example above, the `perform_now` method executes the job in the **current process**.

The `perform_later` function runs the job by invoking the AWS Lambda function associated with it in a **new process**.  It usually runs a few seconds later.

<a id="prev" class="btn btn-basic" href="{% link _docs/routing.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/install.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
