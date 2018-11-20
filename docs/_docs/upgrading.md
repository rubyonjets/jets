---
title: Upgrading Guide
---

Upgrading Jets to some releases might require some extra changes.  For example, the Jets project structure can possible change. Also, some version upgrades require a blue-green deployments.  Here's a summary of the releases requiring some upgrade work.

## Upgrading Releases

The following table summarizes the releases and upgrade paths.

Version | Notes | Blue-Green?
--- | --- | ---
1.1.0 | Added `Jets.boot` to `config.ru`. You can run the `jets upgrade:v1` command to add it. | No
1.0.0 | Added `config/environments` files. You can use the `jets upgrade:v1` command. Going from 0.10.0 to 1.0.0 does not required a blue-green deploy. But if you're going from before 0.10.0, then you will need a blue-green deploy. | No
0.10.0 | Bug fix: CloudFormation routing logical ids changed to allow multiple routes to point to the same controller action. Also removed the managed `Jets::WelcomeController` and consolidated to the managed `Jets::PublicController`. Refer to Upgrade Details. | Yes
0.9.0 | CloudFormation Logical ids changed to be more concise. | Yes

## Upgrade Details

The following section provides a little more detail on each version upgrade. Note, not all versions required more details.

### 1.0.1

The `jets upgrade:v1` command was introduced here. You can use it to upgrade the code structure.

### 0.10.0

In this version, the managed `Jets::WelcomeController` was removed. This means you'll have to update your `config/routes.rb`.  Replace:

```ruby
root "jets/welcome#index"
```

With:

```ruby
root "jets/public#show"
```

You can use the `jets upgrade:v1` command to automatically update the `config/routes.rb` file.

## Reasons

The reason a blue-green deployment sometimes required is that enough of Jets has changed where a regular CloudFormation stack update rolls back.  An example is in `v0.9.0`, Jets changes a few of the CloudFormation logical ids. In this case, CloudFormation fails to create Lambda functions with the same name and switch over to them because the Lambda functions already exist with their old logical ids. If you're seeing the CloudFormation stack rollback after upgrading, you might want to try a blue-green deployment.

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

<a id="prev" class="btn btn-basic" href="{% link _docs/lazy-loading.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/megamode.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
