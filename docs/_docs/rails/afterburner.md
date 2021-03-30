---
title: Rails Support
---

Jets Afterburner mode supports deploying your Rails app requiring little changes to your code. This is an experimental feature.

<div class="video-box"><div class="video-container"><iframe src="https://www.youtube.com/embed/P44Le1VF6us" frameborder="0" allowfullscreen=""></iframe></div></div>

## How It Works

Jets Afterburner mode works by starting a rack subprocess in the [Lambda Execution Context](https://docs.aws.amazon.com/lambda/latest/dg/running-lambda-code.html) and then a normal Jets application proxies to that server. This is accomplished via [Jets Mega Mode]({% link _docs/rails/megamode.md %}). All of this happens transparently. You just deploy from your rails application folder.

## Usage

If your Rails application uses environment variables such as `DATABASE_URL` or `DATABASE_PASSWORD`, Jets needs to know about them prior to deployment in order to make them available to the generated Lambda functions. You should set the variables in `.env` files which should be placed in your Rails project's `.jets/project/` directory. Be sure to read the `.env` file [documentation]({% link _docs/env-files.md %}) so that you know how to name your `.env` files.

    $ cd <your Rails project directory>
    $ mkdir -p .jets/project
    $ touch .jets/project/.env # you should add your environment variables here

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

By default, Jets will infer the project name from the folder you are in.  You can override this with a special `.jets/project/project_name` file.  The first line in `.jets/project/project_name` will be used as the project name if the file exists.

## Advanced customizations

If you want to make Lambda-specific application-wide configurations, you can add config files in the `.jets/project` directory.  For example, you can set the Lamba function memory size for the production environment inside of `.jets/project/config/environments/production.rb`:

```ruby
Jets.application.configure do
  config.function.memory_size = 1024
end
```
Read the documentation for [Function Properties]({% link _docs/function-properties.md %}) to learn about other properties which can be set.

## Notes and Considerations

* Do not add jets to your Rails project's Gemfile. Adding it to the Gemfile might result in bundler being unable to resolve dependencies. Jets is used as a stand-alone tool in Afterburner mode.
* Afterburner mode provides a way to run Rails on Serverless but is not a panacea for all Rails applications. Each and every Rails application is different and likely makes assumptions that it's running on a traditional server not serverless.
* For example, the app might upload files or images to the filesystem. This doesn't work on AWS Lambda because the app doesn't have access to a persistent filesystem. The application would have to be reworked to store files on a distributed store like S3 instead.
* Also, AWS currently limits the total Lambda code size + [Gem Layer]({% link _docs/extras/gem-layer.md %}) to 250MB. AWS Docs [Lambda Limits](https://docs.aws.amazon.com/lambda/latest/dg/limits.html). The baseline Rails gems add up to about 146MB, so you have about 104MB of space left for additional gems.
* For more complex Rails apps, you might want to consider looking into [Jets Mega Mode](https://blog.boltops.com/2018/11/03/jets-mega-mode-run-rails-on-aws-lambda). Mega Mode allows you to selectively run parts of your app in Rails and parts in Jets.
* Most apps just make more sense to run as a Jets app. Jets was built and specifically designed for the serverless world.

## Rails with Jets vs Straight Jets

Generally, it is recommended you run Jets application directly instead of Afterburner mode. Though mostly hidden from a user perspective, there is overhead associated and extra obfuscation with Jets Afterburner. This [Mega Mode Post](https://blog.boltops.com/2018/11/03/jets-mega-mode-run-rails-on-aws-lambda) may help.

Though it is possible to leverage Jets features in Afterburner by adding code to [.jets/project](https://community.rubyonjets.com/t/how-to-test-an-afterburner-job-from-lambda-test-events/203), it's recommended to run Jets natively when possible. When you run a Jets application natively, you also get direct access to the full power of Jets. Some examples are [Jobs]({% link _docs/jobs.md %}), [Events]({% link _docs/events.md %}), and [IAM Policies]({% link _docs/iam-policies.md %}).

## JavaScript Runtime Error

If the Rails rack process fails to start up and you see this error in the CloudWatch logs:

    /opt/ruby/gems/2.5.0/gems/execjs-2.7.0/lib/execjs/runtimes.rb:58:in `autodetect': Could not find a JavaScript runtime. See https://github.com/rails/execjs for a list of available runtimes. (ExecJS::RuntimeUnavailable)

This is because Rails includes the `uglifier` and `coffee-rails` gems, which depend on a javascript runtime. The error means a javascript runtime like node was not found. In recent versions of the AWS Lambda Ruby Runtime, it looks like node is no longer installed. To fix this, uncomment `therubyracer` in your Gemfile. Uglifier will detect that `therubyracer` javascript runtime is available and use that instead.

Another approach that seems to work is to move the `uglifier` and `coffee-rails` gems in the Gemfile `development` group. Jets does not bundle gems in the development group as a part of deployment to Lambda.

## Endpoint request timed out Error

If you are seeing a `Endpoint request timed out` error, it is probably because the rack subprocess failed to start. For performance, the rack subprocess is started outside the lambda handler function and only runs in the cold-start.

Try going farther up the CloudWatch logs to find out where rackup is failing to start. That is the key. It may help to run [jets deploy](https://rubyonjets.com/reference/jets-deploy/) again and watch the logs during deployment time.  The usual errors are a database connection issue or a gem dependency issue.

