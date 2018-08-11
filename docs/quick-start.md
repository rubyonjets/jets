---
title: Quick Start
---

In a hurry? No problem!  Here's a quick start to get going.

{% highlight bash %}
jets new demo
cd demo
jets generate scaffold Post title:string
edit .env.development # adjust to your local database creds
jets db:create db:migrate
jets server
open http://localhost:8888/posts # check out the site
{% endhighlight %}

The `jets server` command starts a server that mimics API Gateway so you can test locally.  Once you're ready, deploy to AWS.

{% highlight bash %}
edit .env.development.deploy # adjust to your remote database creds
jets deploy
{% endhighlight %}

Jets deploy will launch a few CloudFormation templates that will deploy your app as lambda functions and API Gateway routes.

IMAGE OF API GATEWAY AND LAMBDA AND CLOUDFORMATION HERE

Congratulations!  You have successfully deployed your serverless ruby application. It's that simple. 😁

<a id="next" class="btn btn-primary" href="{% link docs.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
