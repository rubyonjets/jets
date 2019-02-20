---
title: Overview
---

## What is Ruby on Jets?

Jets is a Ruby serverless Framework that allows you to create and deploy microservices easily. It includes everything you need to build APIs and deploy them to AWS Lambda. Jets is also perfect for writing functions that glue AWS services and resources together.

## How It Works

You write code and Jets turns your code into Lambda functions and other AWS resources. Jets orchestrates provisioning and deployment so you can focus on writing code, which is what serverless is all about!

## Jets AWS Introduction Series

For those who would like to learn some AWS essentials, you might like this introductory series:

{% assign posts = site.data.intro_series %}
{% for post in posts %}
* [{{ post.title }}]({{ post.url }}){% endfor %}

## Jets Tutorial Series

For those that would like to jump into Jets more directly, you might like this:

{% assign posts = site.data.tutorial_series %}
{% for post in posts limit: 4 %}
* [{{ post.title }}]({{ post.url }}){% endfor %}

## Jets Events Series

For those that would like are interested in connect events with Jets and using it as a Glue Framework.

{% assign posts = site.data.events_series %}
{% for post in posts limit: 4 %}
* [{{ post.title }}]({{ post.url }}){% endfor %}


## Videos

Here are the video playlists for the tutorial series.

{% assign posts = site.data.video_playlists %}
{% for post in posts %}
* [{{ post.title }}]({{ post.url }}){% endfor %}

<a id="prev" class="btn btn-basic" href="{% link quick-start.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/functions.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
