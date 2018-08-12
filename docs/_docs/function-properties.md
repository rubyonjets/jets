---
title: Function Properties
---

Jets ultimately translate ruby code into Lambda functions. Each [Lambda function's properties](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html) can be controlled with Jets. Here are the ways to set the function properties and their order of precedence:

1. function specific properties - highest precedence
2. class-wide function properties
3. global function properties set - lowest precedence

## Function Specific Properties

Specific function properties are set right above the method definition like so:

```ruby
class PostsController < ApplicationController
  timeout 18 # function specific property for the index lambda function
  def index
    posts = Post.scan # should not use scan for production
    render json: {action: "index", posts: posts}
  end
end
```

## Class-wide Function Properties

Class-wide function properties set in the same class file and with a prefix of `class_`.

```ruby
class PostsController < ApplicationController
  class_timeout 22
  timeout 18 # function specific property for the index lambda function
  def index
    posts = Post.scan # should not use scan for production
    render json: {action: "index", posts: posts}
  end

  def new
    render json: params.merge(action: "new")
  end
end
```

For the code above, the `new` method will have a function timeout of 22 seconds and the `index` method will have a function timeout of 18 seconds.

## Global Function Properties

To set function properties globally, edit the function key under the config object in:

`config/application.rb`:

```ruby
Jets.application.configure do
  ...
  config.function.timeout = 10
  # config.function.role = "arn:aws:iam::#{ENV['AWS_ACCOUNT_ID']}:role/service-role/pre-created"
  # config.function.memory_size= 3008
  # config.function.cors = true
  config.function.environment = {
    global_app_key1: "global_app_value1",
    global_app_key2: "global_app_value2",
  }
end
```

## Function Properties Method

In the above example, we use the `timeout` and `class_timeout` method to set function properties. These convenience methods call the `properties` and `class_properties` methods respectively.  These methods allow you to change any property for the lambda function. So you could have done this also:

```ruby
class PostsController < ApplicationController
  class_properties(timeout: 22)
  properties(timeout: 18) # function specific property for the index lambda function
  def index
    posts = Post.scan # should not use scan for production
    render json: {action: "index", posts: posts}
  end
end
```


### Available Function Convenience Methods

Function level | Class level
--- | ---
timeout | class_timeout
environment | class_environment
memory_size | class_memory_size
role | class_role

For the latest list, refer to the source code itself: [lambda/dsl.rb](https://github.com/tongueroo/jets/blob/master/lib/jets/lambda/dsl.rb)

<a id="prev" class="btn btn-basic" href="{% link _docs/app-config.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/prewarming.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
