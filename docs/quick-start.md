---
title: Quick Start
---

In a hurry? No problem!  Here's a quick start to using lono that takes only a few minutes.  The commands below launches a CloudFormation stack.

{% highlight bash %}
$ gem install lono
$ TEMPLATE=ec2 lono new infra
=> Creating new project called infra.
      create  infra
      create  infra/app/definitions/base.rb
      create  infra/app/definitions/development.rb
      create  infra/app/definitions/production.rb
      create  infra/app/templates/example.yml
      create  infra/config/params/base/example.txt
      create  infra/config/params/development/example.txt
      create  infra/config/params/production/example.txt
      create  infra/config/settings.yml
      create  infra/config/variables/base.rb
      create  infra/config/variables/development.rb
      create  infra/config/variables/production.rb
      create  infra/app/scripts
      create  infra/app/user_data
      create  infra/output
=> Installing dependencies with: bundle install
Fetching gem metadata from https://rubygems.org/..
...
Bundle complete! 1 Gemfile dependency, 37 gems now installed.
=> Initialize git repo
...
================================================================
Congrats 🎉 You have successfully created a lono project.

Cd into your project and check things out:

  cd infra

The example template uses a keypair named default. Be sure that keypair exists.  Or you can adjust the KeyName parameter in config/params/base/example.txt. Here are contents of the file:

  InstanceType=t2.micro
  KeyName=default

To launch an example CloudFormation stack:

  lono cfn create example

To re-generate your templates without launching a stack, you can run:

  lono generate

The generated CloudFormation templates are in the output/templates folder.
The generated stack parameters are in the output/params folder.

$ cd infra
$ lono cfn create example # launches stack
{% endhighlight %}

The last command does a few things:

1. Generate templates and params files from `app/definitions` and `app/templates` to `output/templates`.
2. Generate parameter files from `config/params` to `output/params`.
3. Use the `output` files to launch a CloudFormation stack.

The example launches an EC2 instance with a security group. Check out the newly launch stack in the AWS console:

<img src="/img/tutorial/stack-created.png" alt="Stack Created" class="doc-photo">

Congratulations!  You have successfully created a CloudFormation stack with lono. It's that simple. 😁

## Summarized Commands

Here are the commands again in compact summarized form for copy and paste:

```sh
gem install lono
TEMPLATE=ec2 lono new infra
cd infra
lono cfn create example # launches stack
```

<a id="next" class="btn btn-primary" href="{% link docs.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
