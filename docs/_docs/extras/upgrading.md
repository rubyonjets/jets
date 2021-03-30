---
title: Upgrading Guide
---

Upgrading Jets to some releases might require some extra changes.  For example, the Jets project structure can change. Or some version require a manual blue-green deployment.  This page provides a summary of the releases requiring some upgrade work.

## Upgrade Command

A `jets upgrade` command is provided to help with upgrades.  The command is designed to be idempotent. This means it is safe to run repeatedly and will only upgrade the files and structure if needed.  Before running the command, it is recommended to back up your project first just in case though. This usually can be done by committing any unsaved changes to git.

## Upgrading Releases

The following table summarizes the releases and upgrade paths.

Version | Notes | Blue-Green? | Run jets upgrade?
--- | --- | --- | ---
3.0.0 | Added Ruby 2.7 support. Use Serverless Gems for binary gems. | No | No
2.1.1 | Change `config.extra_autoload_paths` to `config.autoload_paths` | No | Yes
2.0.0 | Add csrf forgery protection. The `jets upgrade` commands updates your code with the csrf logic. New apps generated with `jets new` does this already. The routes `namespace` behavior also changed.  Use `prefix` if you prefer the old behavior.  | No | Yes
1.4.11 | Removed vendor/dynomite gem. Must add dynomite to Gemfile now. New apps generated with `jets new` does this.  | No | Yes
1.3.0 | Official AWS Ruby Support added.  Removed longer needed `config.ruby.lazy_load` feature. | No | No
1.2.0 | Set default `config.api.binary_media_types` to `multipart/form-data` to handle binary support.  | No | No
1.1.0 | Added `Jets.boot` to `config.ru`. You can run the `jets upgrade` command to add it. | No | Yes
1.0.0 | Added `config/environments` files. You can use the `jets upgrade` command. Going from 0.10.0 to 1.0.0 does not required a blue-green deploy. But if you're going from before 0.10.0, then you will need a blue-green deploy. | Yes | No
0.10.0 | Bug fix: CloudFormation routing logical ids changed to allow multiple routes to point to the same controller action. Also removed the managed `Jets::WelcomeController` and consolidated to the managed `Jets::PublicController`. Refer to Upgrade Details. | Yes | No
0.9.0 | CloudFormation Logical ids changed to be more concise. | Yes | No

## Upgrade Details

The following section provides a little more detail on each version upgrade. Note, not all versions required more details.

### 3.0.0

* Ruby 2.7 support added. To use Ruby 2.7, just switch your current ruby version a 2.7.x variant and Jets will detect it.
* [Serverless Gems](https://www.serverlessgems.com/) is used for binary gems.
* App views are the underscored name of the controller. They are **not** pluralized. This was a bug and has been fixed.
* The `config.iam_policy` option appends to the default Jets IAM policy, instead of overriding it. Use `config.default_iam_policy` to completely override.

### 2.0.0

* csrf forgery protection added. Need to add `csrf_meta_tags` to the layout for js based non-get calls. Also need to update the stock `crud.js`. And update the `config/application.rb` and with `default_protect_from_forgery = false` when in api mode.  The `jets upgrade` command does this for you.
* Note: The `jets upgrade` command does not update your `form_tag` to the newer `form_with` helper. The `jets generate scaffold` does, though.  Recommend generating a scaffold, comparing the form tags and upgrading as it makes sense. The current `form_tag` though includes authenticity_token so you can leave your forms as-is if needed.
* The routes `namespace` behavior changed. Use the `prefix` method now if you prefer the old behavior. Otherwise, you must move your controllers to modules matching the namespace.

### 1.4.11

* Remove vendor/dynomite. Add dynomite to your Gemfile now if you are using `app/models/application_item.rb`. The `jets new` command has been updated to do this.  Run `jets upgrade` to upgrade.

### 1.3.0

* Use of Official AWS Ruby Support.
* Project gems are built as a Lambda Layer, removing the need to lazy load the gems. The `config.ruby.lazy_load` option has been removed. You can use the `jets upgrade` to automatically remove the option from your config files.

### 1.2.0

Some notable changes for version 1.2.0:

* For binary support, the API Gateway binary_media_types settings needs to have `multipart/form-data`.  With this version, automated blue-green deployments was introduced. So Jets will do an automated blue-green deployment as part of adding the `multipart/form-data` binary_media_types.
* Jets also added managed custom domains for vanity endpoints. This requires an additional minimal Route53 IAM permission. This is noted in [Minimal Deploy IAM]({% link _docs/extras/minimal-deploy-iam.md %}).  You will have to add this permission to your IAM deploy permission.

### 1.0.1

The `jets upgrade` command was introduced here. You can use it to upgrade the code structure.

### 0.10.0

In this version, the managed `Jets::WelcomeController` was removed. This means you'll have to update your `config/routes.rb`.  Replace:

```ruby
root "jets/welcome#index"
```

With:

```ruby
root "jets/public#show"
```

You can use the `jets upgrade` command to automatically update the `config/routes.rb` file.

## Reasons

The reason a blue-green deployment sometimes required is that enough of Jets has changed where a regular CloudFormation stack update rolls back.  An example is in `v0.9.0`, Jets changes a few of the CloudFormation logical ids. In this case, CloudFormation fails to create Lambda functions with the same name and switch over to them because the Lambda functions already exist with their old logical ids. If you're seeing the CloudFormation stack rollback after upgrading, you might want to try a manual [blue-green deployment]({% link _docs/extras/blue-green-deployment.md %}).  Below are some additional notes on blue-green deployments.

It is easy to do a blue-green deployment with Jets, and you will only need to do a blue-green deployment once after upgrading Jets for that version. Once done, you can normally deploy again.

**Important**: With blue-green deployments, the API Gateway endpoint will **change**. Any applications referencing the endpoint will need to be updated.  For this reason, it is recommended to use an API Gateway Custom Domain, so you do not have to update the endpoint in the future.

## In-Place Deploy

Here's a typical in-place deploy:

    cd demo # your project
    bundle update
    jets deploy # in place deploy

## Blue-Green Deployment

For a blue-green deployment, you use `JETS_ENV_EXTRA` to create a brand new Jets environment. You then switch to it and destroy the old environment. First, create the new environment:

    cd demo # your project
    bundle update
    JETS_ENV_EXTRA=2 jets deploy # creates an additional jets environment for your app

Then update the Gateway API Custom Domain to point to the newly deployed `JETS_ENV_EXTRA=2` environment.

### Gateway API Custom Domain

1. Test the new environment and make sure you're happy with it.
2. Go to API Gateway Console.
3. Click on **Custom Domains**.
4. Find the Custom domain you are currently using and click on it.
5. Update the custom domain so it points to the newly created Jets environment.
6. Make sure there's no traffic hitting the old Jets environment. You can do this by checking out the CloudWatch metrics. Nothing should be hitting it aside from the pre-warming requests. You can disable the pre-warming requests manually by using the CloudWatch console also.
7. Destroy the old environment.

