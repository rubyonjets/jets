---
title: Polymorphic Python
---

Polymorphic support for python works like so for the controller code:

`app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  python :python_example
end
```

You add your corresponding python code in the `posts_controller/python` folder:

`app/controllers/posts_controller/python/python_example.py`:

```python
from pprint import pprint
import json
import platform

def lambda_handler(event, context):
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
```

Notice, how with the python code, you must handle returning the proper lambda proxy structure to API Gateway.

## Lambda console

![](/img/docs/poly/poly-lambda-functions-list.png)

On the function show page:

![](/img/docs/poly/poly-lambda-function-python.png)

## Default Handler Name

The default python handler name is `lambda_handler`. The default can be changed with the `handler` method.  Example:

`app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  handler :handle
  python :python_example
end
```

The python code would then look something like this:

```python
def handle(event, context):
  ...
end
```

You can also set the handler for the entire class. Example:

```ruby
class PostsController < ApplicationController
  class_handler :handle
  # ...
end
```

