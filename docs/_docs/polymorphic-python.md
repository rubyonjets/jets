---
title: Polymorphic Python
---

Polymorphic support for python works like so for the controller code:

`app/controllers/posts_controller.rb`:

{% highlight ruby %}
class PostsController < ApplicationController
  python :python_example
end
{% endhighlight %}

You add your corresponding python code in the `posts_controller/python` folder:

`app/controllers/posts_controller/python/python_example.py`:

{% highlight python %}
from pprint import pprint
import json
import platform

def handle(event, context):
    message = 'PostsController#python_example hi from python %s' % platform.python_version()
    return response({'message': message}, 200)

def response(message, status_code):
    return {
        'statusCode': str(status_code),
        'body': json.dumps(message),
        'headers': {
            'Content-Type': 'application/json'
            },
        }
{% endhighlight %}

Notice, how with the python code, you must handle returning the proper lambda proxy structure to API Gateway.

## Default Handler Name

The default handler name is `handle`. This can be changed with the `handler` method.  Example:

`app/controllers/posts_controller.rb`:

{% highlight ruby %}
class PostsController < ApplicationController
  handler :lambda_handler
  python :python_example
end
{% endhighlight %}

The python code would then look something like this:

{% highlight python %}
def lambda_handler(event, context):
  ...
end
{% endhighlight %}

<a id="prev" class="btn btn-basic" href="{% link _docs/polymorphic-support.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/polymorphic-node.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
