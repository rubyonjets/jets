---
title: Polymorphic Node
---

To write your Jets Lambda functions in node, it would look like this:

`app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  node :node_example
end
```

You add your corresponding node code in the `posts_controller/node` folder:

`app/controllers/posts_controller/node/node_example.js`:

```javascript
'use strict';

exports.handler = function(event, context, callback) {
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
```

Notice, how with the node code, you must handle returning the proper lambda proxy structure to API Gateway.

## Lambda console

![The AWS function UI demonstrating implementation of the sample code.](/img/docs/poly/poly-lambda-function-node.png)

## Default Handler Name

The default node handler name is `handler`. The default can be changed with the `handler` method.  Example:

`app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  handler :handle
  node :node_example
end
```

The node code would then look something like this:

```javascript
exports.handle = function(event, context, callback) {
  ...
};
```

You can also set the handler for the entire class. Example:

```ruby
class PostsController < ApplicationController
  class_handler :handle
  # ...
end
```

