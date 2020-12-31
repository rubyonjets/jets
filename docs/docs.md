---
title: Overview
---

## What is Ruby on Jets?

Jets is a Ruby serverless Framework that allows you to create and deploy services easily. It includes everything you need to build APIs and deploy them to AWS Lambda. Jets is also perfect for writing functions that glue AWS services and resources together.

## How It Works

You write code and Jets turns your code into Lambda functions and other AWS resources. Jets orchestrates provisioning and deployment so you can focus on writing code, which is what serverless is all about! Here's a presentation that introduces Jets:

<div class="video-box"><div class="video-container"><iframe src="https://www.youtube.com/embed/a0VKbrgzKso" frameborder="0" allowfullscreen=""></iframe></div></div>

## Jets AWS Introduction Series

For those who would like to learn some AWS essentials, you might like this introductory series:

{% assign posts = site.data.intro_series %}
{% for post in posts %}
* [{{ post.title }}]({{ post.url }}){% endfor %}

## Jets Tutorial Series

For those that would like to jump into Jets more directly, you might like this:

{% assign posts = site.data.tutorial_series %}
{% for post in posts limit: 11 %}
* [{{ post.title }}]({{ post.url }}){% endfor %}

## Jets Events Series

For those interested in connecting events with Jets and using it as a Glue Framework.

{% assign posts = site.data.events_series %}
{% for post in posts limit: 4 %}
* [{{ post.title }}]({{ post.url }}){% endfor %}


## Videos

Here are the video playlists for the tutorial series.

{% assign posts = site.data.video_playlists %}
{% for post in posts %}
* [{{ post.title }}]({{ post.url }}){% endfor %}

