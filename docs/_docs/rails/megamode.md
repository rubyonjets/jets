---
title: Mega Mode
---

Jets Mega Mode supports deploying your Rails app also with little changes to your code.

<div class="video-box"><div class="video-container"><iframe src="https://www.youtube.com/embed/gDLH9ui9ITk" frameborder="0" allowfullscreen=""></iframe></div></div>

With Mega Mode we start up a rack server as subprocess and Jets proxies requests to the underlying rack server. Jets Mega Mode is designed to achieve generic Rack support for frameworks like Rails.  [Jets Afterburner]({% link _docs/rails-support.md %}) is actually implemented by Mega Mode underneath the hood. Here are some aspects of how Mega Mode works.

## Separate Server Process

The rack application is started up as a separate process. This ensures isolation between the Rails project and the Jets project. This is a key point. The Mega Mode approach keeps the Jets project and its dependencies free from colliding with Rails because they are running in separate processes.

Since everything runs in the same local network within the [Lambda Execution context](https://docs.aws.amazon.com/lambda/latest/dg/running-lambda-code.html) the overhead is inconsequential after the cold start.

## Logging

Since the rack sub-application is separate process it means that it's stdout available to the main jets process. Jets accounts for this and automatically adds the rack process stdout to CloudWatch logs. A designation of **Rails** or **Rack** is prepended to the logging output to indicate that the log entry is from the rack subprocess.  Example:

    START RequestId: 3b95bd71-d96a-11e8-ac10-cd7b5b89e808 Version: $LATEST
    Processing by Jets::RackController#process
    Event: ...
    Parameters: {"catchall"=>"posts"}
    Rails: Started GET "/dev/posts" for 52.46.17.96 at 2018-10-26 21:58:12 +0000
    Rails: Processing by PostsController#index as */*
    Rails: PostsController#index request.host "e6k1erf1fg.execute-api.us-west-2.amazonaws.com"
    Rails: Rendering posts/index.html.erb within layouts/application
    Rails: Post Load (1.2ms) SELECT "posts".* FROM "posts"
    Rails: ↳ app/views/posts/index.html.erb:14
    Rails: Rendered posts/index.html.erb within layouts/application (16.0ms)
    Rails: Completed 200 OK in 32ms (Views: 15.3ms | ActiveRecord: 6.8ms)
    Completed Status Code 200 in 0.415373045s
    END RequestId: 3b95bd71-d96a-11e8-ac10-cd7b5b89e808
    REPORT RequestId: 3b95bd71-d96a-11e8-ac10-cd7b5b89e808    Duration: 229.89 ms    Billed Duration: 300 ms Memory Size: 1536 MB    Max Memory Used: 556 MB

## Use of /tmp Folder

Normally, AWS Lambda runs your application on a read-only filesystem. Most Rails applications assume it has filesystem write access. For example, it might create `tmp/cache` folders upon starting up.  Rails gems or plugins might also assume write access. Because of this, the rack application runs from the `/tmp` folder which AWS Lambda allows write access to.

Using the `/tmp` folder also increases the amount of space available to run applications to [512MB](https://docs.aws.amazon.com/lambda/latest/dg/limits.html). This is important because the maximum size of your uncompressed code with Lambda Layers on AWS Lambda is currently limited to [250MB](https://docs.aws.amazon.com/lambda/latest/dg/limits.html).  Using the `/tmp` folder allows for larger rack applications.

## Cold Start Overhead

Since Mega Mode starts a separate rack server process within the Lambda Execution Context, there is some overhead. The overhead depends on your application. If you have configured your Lambda function to at least 1GB of RAM, then the overhead is usually 1-3 seconds. Additional requests after the cold start usually range from 30ms to 300ms.

## Why Mega Mode?

Since there is overhead associated with the Mega Mode approach, you may be wondering why take the approach. Simple. It's the most pragmatic way to get a Rails app running on serverless.

