---
title: Polymorphic Node
---

To use write your Jets Lambda functions in node it would look like this:

`app/controllers/posts_controller.rb`:

{% highlight ruby %}
class PostsController < ApplicationController
  node :node_example
end
{% endhighlight %}

You add your corresponding node code in the `posts_controller/node` folder:

`app/controllers/posts_controller/node/node_example.js`:

{% highlight javascript %}
'use strict';

exports.handle = function(event, context, callback) {
    var message = 'hi from node ' + process.version;
    var body = {'message': message};
    var response = {
      statusCode: "200",
      headers: {
          'Content-Type': 'application/json',
      },
      body: JSON.stringify(body)
    };
    callback(null, response);
};
{% endhighlight %}

Notice, how with the node code, you must handle returning the proper lambda proxy structure to API Gateway.

## Default Handler Name

The default handler name is `handle`. This can be changed with the `handler` method.  Example:

`app/controllers/posts_controller.rb`:

{% highlight ruby %}
class PostsController < ApplicationController
  handler :handler
  node :node_example
end
{% endhighlight %}

The node code would then look something like this:

{% highlight javascript %}
exports.handler = function(event, context, callback) {
  ...
};
{% endhighlight %}




<a id="prev" class="btn btn-basic" href="{% link _docs/polymorphic-node.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/crud-tutorials.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
