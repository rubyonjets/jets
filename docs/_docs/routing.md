---
title: Controllers
---

You connect Lambda functions to API Gateway URL endpoints with a routes file:

config/routes.rb:

{% highlight ruby %}
Jets.application.routes.draw do
  get  "posts", to: "posts#index"
  get  "posts/new", to: "posts#new"
  get  "posts/:id", to: "posts#show"
  post "posts", to: "posts#create"
  get  "posts/:id/edit", to: "posts#edit"
  put  "posts", to: "posts#update"
  delete  "posts", to: "posts#delete"

  resources :comments # expands to the RESTful routes above

  any "posts/hot", to: "posts#hot" # GET, POST, PUT, etc request all work
end
{% endhighlight %}

Test your API Gateway endpoints with curl or postman. Note, replace the URL endpoint with the one that is created:

{% highlight sh %}
$ curl -s "https://quabepiu80.execute-api.us-east-1.amazonaws.com/dev/posts" | jq .
{
  "hello": "world",
  "action": "index"
}
{% endhighlight %}

<a id="prev" class="btn btn-basic" href="{% link _docs/controllers.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/workers.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
