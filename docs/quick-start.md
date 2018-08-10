---
title: Quick Start
---

In a hurry? No problem!  Here's a quick start to using jets that will get you going.

{% highlight bash %}
jets new demo
cd demo
jets generate scaffold Post title:string
jets db:create db:migrate
jets server
open http://localhost:8888/posts
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
