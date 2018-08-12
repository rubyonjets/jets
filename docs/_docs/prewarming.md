---
title: Prewarming
---

Jets supports prewarming your application to remedy the Lambda cold start issue.  Prewarming with a concurrency of 1 is enabled by default.  To adjust the prewarming settings, edit your `config/application.rb`. Example:

```ruby
Jets.application.configure do
  # ...
  config.prewarm.enabled = true # default: enabled
  config.prewarm.rate = "30 minutes" # default: 30 minutes
  config.prewarm.concurrency = 1 # default: 1
end
```

## Prewarm After Deployment

After a deployment finishes, Jets automatically prewarms the app with a concurrency of 1.  This keeps your application nice and fast immediately.

## Custom Prewarming

Jets supports prewarms all ruby functions in your application. If you want to prewarm a specific high traffic function then you can create your own custom prewarm job.  Here's a starter example:

app/jobs/prewarm_job.rb:

```ruby
class PrewarmJob < ApplicationJob
  class_timeout 300
  class_memory 3008
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


Jets::Commands::Call.new(function_name, '{"_prewarm": "1"}', @options).run unless ENV['TEST']


<a id="prev" class="btn btn-basic" href="{% link _docs/function-properties.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/env-files.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
