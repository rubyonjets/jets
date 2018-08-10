---
title: Structure
---

Ufo creates a `.ufo` folder within your project which contains the required files used by ufo to build and deploy docker images to ECS.  The standard directory structure of the `.ufo` folder looks like this:

{% highlight sh %}
.
├── app
│  ├── controllers
│  ├── helpers
│  ├── javascript
│  ├── jobs
│  ├── models
│  └── views
├── bin
├── config
│  ├── application.rb
│  ├── database.yml
│  ├── dynamodb.yml
│  └── routes.rb
│  ├── 404.html
│  ├── 422.html
│  ├── 500.html
│  ├── favicon.ico
│  ├── foo.html
│  ├── index.html
│  └── test
├── spec
│  ├── controllers
│  ├── fixtures
│  └── spec_helper.rb
└── tmp
{% endhighlight %}

The table below covers the purpose of each folder and file.

File / Directory  | Description
------------- | -------------
output  | The folder w

Now that you know where the ufo configurations are located and what they look like, let’s use ufo!

<a id="prev" class="btn btn-basic" href="">Back</a>
<a id="next" class="btn btn-primary" href="">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

