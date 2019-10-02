---
title: Mounting Rails Apps
---

Rails applications are Rack compatible. So, in theory, you can also mount a Rails application in routes. However, it is not currently recommended.  Instead, use [Afterburner]({% link _docs/rails/afterburner.md %}) and [Mega Mode]({% link _docs/rails/megamode.md %}) to run a Rails app.

## Why?

Rails is its own unique beast. You have to strip down a lot of Rails functionality with the mount approach.  The end result is that the app is hardly useable.  Here is some context, thoughts, and reasons to help understand this.

## Same Process

As mentioned in [Rails Support]({% link _docs/rails-support.md %}), Jets allows several approaches to get a Rails application running on serverless. With the [Afterburner]({% link _docs/rails/afterburner.md %}) and [Mega Mode]({% link _docs/rails/megamode.md %}) approach, Jets starts the Rails application as a **separate** standalone process. This results in isolating the Rails and Jets app as independent processes.

With the Rack mount approach, Jets calls the Rails app within the **same** process.

## Speed

The main benefit would then be speed. Jets invokes `Rails.application.call` directly. This removes the extra overhead penalty that occurs on the cold start. So, you may be thinking:

> That's awesome! That's definitely the way to go.

Let's cover some of the disadvantages.

## Dependency Collisions

Because Jets and Rails apps are running within the **same** process, they use the same memory space and will use the same set of gems. Bundler may not be able to resolve the gems with both Jets and Rails apps. The odds of gem dependencies collision is much higher. Even simple Rails applications with a few additional dependencies may not be runnable.

## Project Naming Collisions

It is also possible to have project naming collisions. For example, you must remove or rename the `ApplicationController` in the Jets project if you are going to mount a Rails application. This is because Rails applications already contain an `ApplicationController`. You cannot have classes with the same name in both projects.  A `Post` ActiveRecord model in both projects would also introduce a collision.  Remember, the apps share the same memory space.

## Read-Only Filesystem

Rails applications assume they are running on traditional infrastructure, not on an AWS Lambda serverless environment. AWS Lambda functions run on a read-only filesystem. A Rails application can write to the filesystem. For example, the `logs` or `tmp/cache` folder. Rails baseline gems like bootsnap also assume write access:

![](/img/docs/rails/mount-bootsnap-write-access.png)

Essentially, you have to make sure that your Rails app and all its gems do not write to the filesystem.  It's an uphill battle. With the Afterburner and Mega Mode approach, Jets runs the Rails application in the system `/tmp` folder, which does allow write access.

## Code Size Limit

There is currently a 250MB code size package limit for AWS Lambda. When including the Rails baseline gems and project code it easily puts the code size over the limit. Stripping down parts of Rails really starts to get gnarly. Note, Lambda will likely change this limit in the future.

## Stripping It All Down

Ultimately, you have to strip down much of Rails functionality to get it running as a mounted app. Note, I have also experimented with a lighter Rails engine and have also ran into similar quirks. So it is currently not recommendeded to run a Rails application mounted as a Jets route .
