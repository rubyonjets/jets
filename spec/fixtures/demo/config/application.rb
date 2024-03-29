module Demo
  class Application < Jets::Application
    config.project_name = "demo"
    # config.extra = 2
    # config.autoload_paths = []

    config.function.timeout = 30
    # config.function.memory_size = 3008
    # config.function.cors = true
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

    config.controllers.default_protect_from_forgery = false
  end
end
