---
title: Rails Support (Afterburner mode)
---

Jets supports deploying Rails applications usually without any changes to your code.

## Usage

If your Rails application uses environment variables such as `DATABASE_URL` or `DATABASE_PASSWORD`, Jets needs to know about them prior to deployment in order to make them available to the generated Lambda functions. You should set the variables in `.env` files which should be placed in your Rails project's `.jets/app/` directory. Be sure to read the `.env` file [documentation]({% link _docs/env-files.md %}) so that you know how to name your `.env` files.

    $ cd <your Rails project directory>
    $ mkdir -p .jets/app
    $ touch .jets/app/.env # you should add your environment variables here

Once your `.env` files are configured, just do the following to deploy your Rails app:

    $ gem install jets # note: do not add jets to your Rails project's Gemfile
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

By default, Jets will infer the project name from the folder you are in.  You can override this with a special `.jets/app/project_name` file.  The first line in `.jets/app/project_name` will be used as the project name if the file exists.

## Advanced customizations

If you want to make Lambda-specific application-wide configurations, you can add config files in the `.jets/app` directory.  For example, you can set the Lamba function memory size for the production environment inside of `.jets/app/config/environments/production.rb`:

```ruby
Jets.application.configure do
  config.function.memory_size = 1024
end
```
Read the documentation for [Function Properties]({% link _docs/function-properties.md %}) to learn about other properties which can be set.

## Notes

* Don't add jets to your Rails project's Gemfile. Adding it to the Gemfile might result in bundler being unable to resolve dependencies.
* AWS currently limits the total Lambda code size + [Gem Layer]({% link _docs/gem-layer.md %}) to 250MB. AWS Docs [Lambda Limits](https://docs.aws.amazon.com/lambda/latest/dg/limits.html). The baseline Rails gems add up to about 146MB, so you have about 104MB of space left for additional gems.

<a id="prev" class="btn btn-basic" href="{% link _docs/upgrading.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/rack.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
