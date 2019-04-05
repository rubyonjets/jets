## Introducing Jets

<div class="video-box"><div class="video-container"><iframe src="https://www.youtube.com/embed/17Y3AJl9dw4" frameborder="0" allowfullscreen=""></iframe></div></div>

## Jets Introduction Series

Introductions are focused on AWS fundamental essentials.

{% assign posts = site.data.intro_series %}
{% for post in posts %}
* [{{ post.title }}]({{ post.url }}){% endfor %}

## Jets Tutorial Series

Tutorials are focused on Jets fundamentals.

{% assign posts = site.data.tutorial_series %}
{% for post in posts %}
* [{{ post.title }}]({{ post.url }}){% endfor %}

## Jets Articles

Articles, tutorials, and demos on Jets.

{% assign posts = site.data.articles %}
{% for post in posts %}
* [{{ post.title }}]({{ post.url }}){% endfor %}

## Tutorials

* [HTML ActiveRecord Tutorial]({% link _docs/crud-html-activerecord.md %})
* [JSON ActiveRecord Tutorial]({% link _docs/crud-json-activerecord.md %})

## Videos

{% assign posts = site.data.video_playlists %}
{% for post in posts %}
* [{{ post.title }}]({{ post.url }}){% endfor %}
