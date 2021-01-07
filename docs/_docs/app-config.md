---
title: Application Configuration
---

You can set application-wide configurations in the `config/application.rb` file. You can configure global things like project_name, autoload_paths, function timeout, memory size, etc. Example:

`config/application.rb`:

```ruby
Jets.application.configure do
  config.project_name = "demo"

  # config.prewarm.rate = '30 minutes' # default is '30 minutes'
  # config.prewarm.concurrency = 1 # default is 1
  # config.env_extra = 2 # change also set this with JETS_ENV_EXTRA
  # config.autoload_paths = []

  config.function.timeout = 30
  # config.function.role = "arn:aws:iam::#{ENV['AWS_ACCOUNT_ID']}:role/service-role/pre-created"
  # config.function.memory_size = 3008
  # config.function.cors = false
  config.function.environment = {
    global_app_key1: "global_app_value1",
    global_app_key2: "global_app_value2",
  }

  # More examples:
  # config.function.dead_letter_queue = { target_arn: "arn" }
  # config.function.vpc_config = {
  #   security_group_ids: [ "sg-1", "sg-2" ],
  #   subnet_ids: [ "subnet-1", "subnet-2" ]
  # }
  # The config.function settings to the CloudFormation Lambda Function properties.
  # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html
  # Underscored format can be used for keys to make it look more ruby-ish.

  # config.api.authorization_type = "AWS_IAM" # default is 'NONE' https://amzn.to/2qZ7zLh
  # config.api.binary_media_types = ['multipart/form-data'] # default is ['multipart/form-data'] # Changing this will update the API Gateway DNS
  # config.api.endpoint_type = 'PRIVATE' # Default is 'EDGE' https://amzn.to/2r0Iu2L, you need to set an endpoint_policy if this is 'PRIVATE'
  # config.api.endpoint_policy = {} # Default is nil https://amzn.to/2r0Iu2L
end
```

## Environment Specific Configs

You can set specific configs for different JETS_ENV in the `config/environments` folder. Examples:

config/environments/development.rb:

```ruby
Jets.application.configure do
  config.function.memory_size = 1536
end
```

config/environments/production.rb:

```ruby
Jets.application.configure do
  config.function.memory_size = 2048
end
```

