---
title: Prewarming
---

**UPDATE 12/3/2019**: AWS has released [Provisioned Concurrency for Lambda Functions](https://aws.amazon.com/blogs/aws/new-provisioned-concurrency-for-lambda-functions/) which essentially keeps the Lambda functions warm. It moves the cold start from invocation time to the Lambda function build time. Refer to the [Provisioned Concurrency pricing](https://aws.amazon.com/lambda/pricing/) for cost details.

Provisioned Concurrency is configured via a property on the [AWS::Lambda::Alias](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-lambda-alias-provisionedconcurrencyconfiguration.html) resource. Jets does not yet currently support this.  Support will be added in the future. PRs are welcome and will be considered. 😁

Jets supports prewarming your application to remedy the Lambda cold start issue.  Prewarming is enabled by default.  Only [Controller]({% link _docs/controllers.md %}) functions are prewarmed. To adjust the prewarming settings, edit your `config/application.rb`. Example:

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

Concurrency can be helpful if requests are coming in at the same time in parallel. Example: The Lambda function gets 60 requests/minute and each request takes 1 second to process.

* Case 1: All 60 requests come in at the same time within the first second. Desired concurrency should be 60 otherwise 59 of 60 requests will be hit with a cold start (in worst case scenario).
* Case 2: The 60 requests come in serially each second for a minute. The same lambda "container" will be able to serve all the requests without a cold start in theory.

Same would apply on traditional servers like Puma where you need more Puma threads and or processes to handle increased concurrency.

Option | Explanation
--- | ---
rate | This controls how often the prewarming job runs.
concurrent | For each prewarming job run, this controls how many times in parallel to hit the functions with a prewarm request.

For example, with a rate of 2 hours and concurrent of 2, this results in the Lambda functions being called with a prewarm request 48 times after 24 hours (24 hours x 2).

To execute prewarming, Jets will create two Lambda functions:

Name | Explanation
--- | ---
warm | If concurrent is `1`.
torch | If concurrent is greater `1`, the torch job will concurrently call the `warm` job.

## Public Ratio

The `prewarm.public_ratio` activates extra prewarming for the internal `jets/public_controller.rb`.  The `jets/public_controller.rb` handles serving static files out of the `public` folder. The `prewarm.public_ratio` tells Jets to prewarm the public_controller's lambda function a little bit extra. You can tune the extra prewarming ratio higher or lower according to your needs.

Note: Even though you can serve assets out of the public folder directly, it is recommended to use the `asset_path` helper which will serve these files out of s3 instead when the app is running on API Gateway and Lambda.  For more info about [Asset Serving]({% link _docs/extras/assets-serving.md %}) refer to the docs.

## Rack Ratio

The `prewarm.rack_ratio` activates extra prewarming for the internal `jets/rack_controller.rb`.  This prewarming only occurs if you're running a Rails app via Jets.

This is useful for Mega Mode, where requests from the main Jets application are passed to a single `jets/rack#process` controller endpoint. This means that this Lambda function could require additional prewarming. You can tune the ratio up or down for your needs with the `prewarm.rack_ratio` setting.

## Prewarm After Deployment

After a deployment finishes, Jets automatically prewarms the app immediately.  This keeps your application nice and fast.

## Prewarm Custom Headers

Jets appends an `x-jets-prewarm-count` header to the response to help you see if the lambda function was prewarmed. The header looks like this:

![Screenshot emphasizing the x-jets-prewarm-count header](/img/docs/prewarm-header.png)

We can see that the lambda function had been prewarmed once and called 4 times since the last time AWS Lambda recycled the Lambda function.

## Custom Prewarming

Jets prewarms most Ruby functions in your application with the same weight. If you want to prewarm a specific function that gets an extremely high volume of traffic, you can create a custom prewarm job.  Here's a starter example:

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

