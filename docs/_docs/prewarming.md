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
  config.prewarm.public_ratio = 3 # default: 3
  config.prewarm.rack_ratio = 5 # default: 5 # only with megamode
end
```

## Rate vs Concurrency

Option | Explanation
--- | ---
rate | This controls how often the prewarming job runs.
concurrent | For each prewarming job run, this controls how many times in parallel to hit the functions with a prewarm request.

For example, with a rate of 2 hours and concurrent of 2, this results in the Lambda functions being called with a prewarm request 24 times after 24 hours (12 hours x 2).

## Public Ratio

The `prewarm.public_ratio` activates extra prewarming for the internal `jets/public_controller.rb`.  The `jets/public_controller.rb` handles serving static files out of the `public` folder. The `prewarm.public_ratio` tells Jets to prewarm the public_controller's lambda function a little bit extra. You can tune the extra prewarming ratio higher or lower according to your needs.

Note: Even though you can serve assets out of the public folder directly, it is recommended to use the `asset_path` helper which will serve these files out of s3 instead when the app is running on API Gateway and Lambda.  For more info about [Asset Servering]({% link _docs/assets-serving.md %}) refer to the docs.

## Rack Ratio

The `prewarm.rack_ratio` activates extra prewarming for the internal `jets/rack_controller.rb`.  This prewarming only occurs if [Mega Mode]({% link _docs/megamode.md %}) has been set up. Mega Mode and [Rails Support]({% link _docs/rails-support.md %}) can be be set up with the [jets import:rails]({% link _reference/jets-import-rails.md %}) command.

This is useful because in Mega Mode, requests from the main Jets application are passed to a single jets/rack#process controller endpoint. This means that this Lambda function could require additional prewarming. You can tune the ratio up or down for your needs with the `prewarm.rack_ratio` setting.

## Prewarm After Deployment

After a deployment finishes, Jets automatically prewarms the app immediately.  This keeps your application nice and fast.

## Prewarm Custom Headers

Jets appends a `x-jets-prewarm-count` header to the response to help you see if the lambda function was prewarmed. The header looks like this:

![](/img/docs/prewarm-header.png)

We can see that the lambda function had been prewarmed once and called 4 times since the last time AWS Lambda recycled the Lambda function.

## Custom Prewarming

Jets prewarms most Ruby functions in your application with the same weight. If you want to prewarm a specific function that gets a high volume of traffic, you can create a custom prewarm job.  Here's a starter example:

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

<a id="prev" class="btn btn-basic" href="{% link _docs/managed-iam-policies.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/env-files.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
