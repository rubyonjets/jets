---
title: Quick Start
nav_order: 1
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

The `jets server` command starts a server that mimics API Gateway so you can test locally.  Open [http://localhost:8888/posts](http://localhost:8888/posts) and check out the site. Note, the `DATABASE_URL` format looks like this: `mysql2://dbuser:dbpass@localhost/demo_dev?pool=5`

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

{% include prev_next.md %}