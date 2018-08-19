---
title: Quick Start
---

In a hurry? No problem!  Here's a quick start to get going.

## Local Testing

    gem install jets
    jets new demo
    cd demo
    jets generate scaffold Post title:string
    vim .env.development # edit with local db settings
    jets db:create db:migrate
    jets server

The `jets server` command starts a server that mimics API Gateway so you can test locally.  Open [http://localhost:8888/posts](http://localhost:8888/posts) and check out the site. Note, the `DATABASE_URL` format looks like this: `postgresql://dbuser:dbpass@localhost/demo_dev?pool=5`

Create some posts records. The posts page should look something like this:

![](/img/quick-start/posts-index.png)

## Deploy to AWS Lambda

Once you're ready, edit the `.env.development.remote` with your remote database settings and deploy to AWS.

    $ vim .env.development.remote # adjust with remote db settings
    $ jets deploy
    API Gateway Endpoint: https://puc3xyk4cj.execute-api.us-west-2.amazonaws.com/dev/

Jets deploy creates the corresponding AWS Lambda Functions and API Gateway resources.

Lambda Functions:

![](/img/quick-start/demo-lambda-functions.png)

API Gateway:

![](/img/quick-start/demo-api-gateway.png)

Congratulations!  You have successfully deployed your serverless ruby application. It's that simple. 😁

<a id="next" class="btn btn-primary" href="{% link docs.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
