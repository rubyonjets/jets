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

After a deployment finishes, Jets automatically prewarms the app with a concurrency of 1.  This keeps your application nice and fast immediately.

<a id="prev" class="btn btn-basic" href="{% link _docs/function-properties.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/env-files.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
