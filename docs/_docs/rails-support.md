---
title: Rails Support
---

Jets supports deploying Rails applications usually without any changes to your code.

<div class="video-box"><div class="video-container"><iframe src="https://www.youtube.com/embed/_o-CmDo2wyo" frameborder="0" allowfullscreen=""></iframe></div></div>

## Usage

Rails applications require some environment variables like `DATABASE_URL` . These should be configured before you deploy your app. You can configure them in [env files]({% link _docs/env-files.md %}) like `.jets/app/.env` within your Rails project.

    $ gem install jets # outside of Gemfile
    $ git clone https://github.com/tongueroo/demo-rails
    $ cd demo-rails
    $ mkdir -p .jets/app
    $ vim .jets/app/.env # add your env variables
    $ jets deploy
    => Rails app detected: Enabling Jets Afterburner to deploy to AWS Lambda.
    ...
    Deploying CloudFormation stack with jets app!
    05:05:11PM UPDATE_IN_PROGRESS AWS::CloudFormation::Stack demo-rails-dev User Initiated
    ...
    05:06:48PM UPDATE_COMPLETE AWS::CloudFormation::Stack demo-rails-dev
    Stack success status: UPDATE_COMPLETE
    Time took for stack deployment: 1m 36s.
    Prewarming application.
    API Gateway Endpoint: https://jp65zxlwf8.execute-api.us-west-2.amazonaws.com/dev/
    $

## Setting the Project Name

By default, Jets will infer the project name from the folder you are in.  You can override this with a special `.jets/app/project_name` file.  The contents of `.jets/app/project_name` will be used as the project name if it exists.

## Customizations with .jets/app

Additionally, you can override things like [Function Properties]({% link _docs/function-properties.md %}) by adding files to your `.jets/app` folder.  For example, here's how you set the timeout for development environments with `.jets/app/config/environments/development.rb`:

```ruby
Jets.application.configure do
  config.function.memory_size = 1024
end
```

## Notes

* Install jets outside of the Gemfile of the Rails project. Adding it to the Gemfile might result in bundler being unable to unresolved dependencies. In Afterburner mode Jets works as a standalone tool.
* AWS currently limits the total Lambda code size + [Gem Layer]({% link _docs/gem-layer.md %}) to 250MB. AWS Docs [Lambda Limits](https://docs.aws.amazon.com/lambda/latest/dg/limits.html). The baseline Rails gems add up to about 146MB, so we have about 104MB of space left for additional gems.

<a id="prev" class="btn btn-basic" href="{% link _docs/upgrading.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/rack.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
