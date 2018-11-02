---
title: Mega Mode Considerations
---

Jets Mega Mode is designed to achieve Rack support in the most seamless fashion possible.  Here are some aspects of how Mega Mode works.

## Reconfiguration Injection

Upon `jets deploy`, the jets build process reconfigures the rack application and injects the necessary changes to run the rack application on AWS Lambda.  This minimizes the changes you might have to make manually.  Here's a list of some injected changes for a Rails rack app.

1. The [jets-rails](https://github.com/tongueroo/jets-rails) gem is added to the Gemfile. The jets-rails gem adjusts the Rails application so it works with AWS Lambda and API Gateway.  Notably, it adjusts the application to account for API Gateway stage urls.
2. The Rails logger is set up to send output to CloudWatch Logs also. This is helpful for debugging.
3. A `config/initializers/jets.rb` initializer is added to override some settings like assets pipeline settings and account for the API Gateway stage name.
4. The `Gemfile` is checked for a ruby declaration and comments it out.  Jets packages its own version of ruby. So the ruby declaration is not necessary and can cause issues when it mismatches with the Jets ruby version.

## Separate Server Process

The rack application is started up as a separate process. This ensures isolation and makes sure that the Rack project's Ruby code cannot collide with the main Jets application and vice versa.  Since everything runs in the same local network within the [Lambda Execution context](https://docs.aws.amazon.com/lambda/latest/dg/running-lambda-code.html) the overhead is inconsequential.

## Logging

Since the rack sub-application is separate process it means that it's stdout avaiable to the main jets process. Jets accounts for this and automatically adds the rack process stdout to CloudWatch logs. A designation of **Rails** or **Rack** is prepended to the logging output to indicate that the log entry is from the rack subprocess.  Example:

    START RequestId: 3b95bd71-d96a-11e8-ac10-cd7b5b89e808 Version: $LATEST
    Rails: Started GET "/dev/posts" for 52.46.17.96 at 2018-10-26 21:58:12 +0000
    Rails: Processing by PostsController#index as */*
    Rails: PostsController#index request.host "e6k1erf1fg.execute-api.us-west-2.amazonaws.com"
    Rails: Rendering posts/index.html.erb within layouts/application
    Rails: Post Load (1.2ms) SELECT "posts".* FROM "posts"
    Rails: ↳ app/views/posts/index.html.erb:14
    Rails: Rendered posts/index.html.erb within layouts/application (16.0ms)
    Rails: Completed 200 OK in 32ms (Views: 15.3ms | ActiveRecord: 6.8ms)
    Processing by Jets::RackController#process
    Event: ...
    Parameters: {"catchall"=>"posts"}
    Completed Status Code 200 in 0.415373045s
    END RequestId: 3b95bd71-d96a-11e8-ac10-cd7b5b89e808
    REPORT RequestId: 3b95bd71-d96a-11e8-ac10-cd7b5b89e808    Duration: 229.89 ms    Billed Duration: 300 ms Memory Size: 1536 MB    Max Memory Used: 556 MB

## Use of /tmp Folder

Normally, AWS Lambda runs your application on a read-only filesystem. Rails assumes it has access to write to the filesystem. For example, it might create `tmp/cache` folders upon starting up.  Rails gems or plugins might also assume write access. Because of this, the rack application runs from the `/tmp` folder which AWS Lambda allows write access to.

Using the `/tmp` folder also increases the amount of space available to run applications to [512MB](https://docs.aws.amazon.com/lambda/latest/dg/limits.html). This is important because the maximum size of your uncompressed code on AWS Lambda is limited to [250MB](https://docs.aws.amazon.com/lambda/latest/dg/limits.html).  A barebones Rails app, with gems, and the Ruby intrepreter sizes in at about 250MB. Using the `/tmp` folder allows for larger applications.

## Lazy Loading

To take advantage of the `/tmp` space Jets lazy loads files into it.  [Lazy loading]({% link _docs/lazy-loading.md %}) means the bundled RubyGems and libraries are loaded as part of the first Lambda request within the [Lambda Execution Context](https://docs.aws.amazon.com/lambda/latest/dg/running-lambda-code.html).

The [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/limits.html) recommends:

> Each Lambda function receives an additional 512MB of non-persistent disk space in its own /tmp directory. The /tmp directory can be used for loading additional resources like dependency libraries or data sets during function initialization.

Lazy Loading adds overhead on the first Lambda request of about 10 seconds.  This performance is addressed by [Prewarming]({% link _docs/prewarming.md %}) the application.  Additional requests after the prewarm request are in the milliseconds range. A Jets request ranges in the 10s of milliseconds and a Rails request ranges in the 100s of milliseconds, usually from 50ms to 500ms.

<a id="prev" class="btn btn-basic" href="{% link _docs/rails-support.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/database-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
