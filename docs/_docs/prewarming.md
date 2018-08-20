---
title: Prewarming
---

Jets supports prewarming your application to remedy the Lambda cold start issue.  Prewarming is enabled by default.  To adjust the prewarming settings, edit your `config/application.rb`. Example:

```ruby
Jets.application.configure do
  # ...
  config.prewarm.enable = true # default: enabled
  config.prewarm.rate = "30 minutes" # default: 30 minutes
  config.prewarm.concurrency = 2 # default: 2
end
```

## Prewarm After Deployment

After a deployment finishes, Jets automatically prewarms the app immediately.  This keeps your application nice and fast.

## Prewarm Custom Headers

Jets appends a `x-jets-prewarm-count` header to the response to help you see if the lambda function was prewarmed. The header looks like this:

![](/img/docs/prewarm-header.png)

We can see that the lambda function had been prewarmed once and called 4 times since the last time AWS Lambda recycled the Lambda function.

## Custom Prewarming

Jets prewarms all Ruby functions in your application with the same weight. If you want to prewarm a specific function that gets a high volume of traffic, you can create a custom prewarm job.  Here's a starter example:

app/jobs/prewarm_job.rb:

```ruby
class PrewarmJob < ApplicationJob
  class_timeout 30
  class_memory 512
  rate '30 minutes'
  def hot_page
    function_name = "posts_controller-index"
    threads = []
    10.times do
      threads << Thread.new do
        Jets::Preheat.warm(function_name)
      end
    end
    threads.each { |t| t.join }
    "Finished prewarming #{function_name}."
  end
end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/iam-policies.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/env-files.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
