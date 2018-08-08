---
title: "Tutorial: Edit Template Lono"
---

The imported AutoScaling template contains a Load Balancer and AutoScaling.  It is designed for web applications.  Let's say we still wanted AutoScaling but do not need the Load Balancer.  A common example of this use case is an AutoScaling worker or queue tier.  We can achieve this in several ways.

## Lono Phases Review

First, let's review the lono phases:

<img src="/img/tutorial/lono-flowchart.png" alt="Stack Created" class="doc-photo lono-flowchart">

Lono introduces a Compile phase where it takes the `app/templates` files, uses ERB variables, and produces different templates in the `output/templates` folder.

We'll show you 2 approaches so you can get a sense, learn, and decide when you want to use one approach over the other. The 2 approaches:

1. Compiling Different Templates with Lono
2. Using Native CloudFormation Logical Constructs

## Compiling Different Templates Approach

Compiling different templates is pretty straightforward with lono templates.  The source code for these changes are in the lono-constructs branch of [lono-tutorial-autoscaling](https://github.com/tongueroo/lono-tutorial-autoscaling/blob/native-constructs/app/templates/autoscaling.yml).  Let's take a look at the relevant [changes](https://github.com/tongueroo/lono-tutorial-autoscaling/compare/lono-constructs).

We changed the `app/definitions/base.rb`:

Before:

```ruby
template "autoscaling" do
```

After:

```ruby
template "autoscaling-web" do
  source("autoscaling")
  variables(load_balancer: true)
end
template "autoscaling-worker" do
  source("autoscaling")
  variables(load_balancer: false)
end
```

Then we added `<% if @load_balancer %>` checks to the sections of the template where we want to turn on and off the load balancer.  The template is large so here is a link to the [autoscaling.yml code](https://github.com/tongueroo/lono-tutorial-autoscaling/blob/lono-constructs/app/templates/autoscaling.yml) and the [compare view](https://github.com/tongueroo/lono-tutorial-autoscaling/compare/lono-constructs) that adds this adjustment.

### Lono Generate

It is helpful to generate the templates and verify that the files in `output/templates` look like what we expect before launching.

```
$ lono generate
Generating CloudFormation templates, parameters, and scripts
No detected app/scripts
Generating CloudFormation templates:
  output/templates/autoscaling-web.yml
  output/templates/autoscaling-worker.yml
Generating parameter files:
  output/params/autoscaling.json
$
```

You can also use `lono summary` to see that the resources are different. Here's the output of `lono summary` with the parameters info filtered out:

```
$ lono summary autoscaling-web
Resources:
  2 AWS::AutoScaling::ScalingPolicy
  2 AWS::CloudWatch::Alarm
  1 AWS::AutoScaling::LaunchConfiguration
  1 AWS::ElasticLoadBalancingV2::LoadBalancer
  1 AWS::ElasticLoadBalancingV2::Listener
  1 AWS::ElasticLoadBalancingV2::TargetGroup
  1 AWS::SNS::Topic
  1 AWS::EC2::SecurityGroup
  1 AWS::AutoScaling::AutoScalingGroup
  9 Total
$ lono summary autoscaling-worker
Resources:
  2 AWS::AutoScaling::ScalingPolicy
  2 AWS::CloudWatch::Alarm
  1 AWS::SNS::Topic
  1 AWS::AutoScaling::AutoScalingGroup
  1 AWS::AutoScaling::LaunchConfiguration
  1 AWS::EC2::SecurityGroup
  6 Total
$
```

We can see that `autoscaling-web` has 9 resources and `autoscaling-worker` has 6 resources.  That's what we should expect.

### Launch Stacks

When things look good, launch both stacks:

```
lono cfn create autoscaling-web --param autoscaling
lono cfn create autoscaling-worker --param autoscaling
```

You should see the new stacks now. It should look something like this:

<img src="/img/tutorial/autoscaling-both-stacks.png" alt="Stack Created" class="doc-photo lono-flowchart">

Note, we're using the same `output/params/autoscaling.json` param file from the original template by specifying the `--param autoscaling` option.  Another way to is to make a copy of the params file for each template like so:

```
cp config/params/base/autoscaling{,-web}.txt
cp config/params/base/autoscaling{,-worker}.txt
```

Then you can edit the files and adjust the new parameters to what you want.  As an added benefit of using parameter files with matching names as their template output names, the `lono cfn create` commands become simple again:

```
lono cfn create autoscaling-web
lono cfn create autoscaling-worker
```

This is due to conventions that lono uses. If no param option is provided, then the convention is for the param file to default to the name of the template option. The conventions covered in detailed in [Conventions]({% link _docs/conventions.md %}).

### Clean Up

Let's do a little clean up and delete some of the stacks before continuing with the `lono cfn delete` command:

```
lono cfn delete autoscaling-web
lono cfn delete autoscaling-worker
lono cfn delete autoscaling
```

### Congrats
Congraluations 🎉 You have successfully added conditional logic to CloudFormation templates that decides whether or not to create a Load Balancer.
