# Jets::Cfn::TemplateBuilders does not stick to the TemplateBuilders::Interface.
# It builds the properties of a function. Usage:
#
#   builder = FunctionProperties::PythonBuilder.new(task)
#   buider.properties
#   buider.map.logical_id # to access Function's logical id
#
module Jets::Cfn::TemplateBuilders::FunctionProperties
  class BaseBuilder
    def initialize(task)
      @task = task
    end

    def map
      @map ||= Jets::Cfn::TemplateMappers::LambdaFunctionMapper.new(@task)
    end

    def properties
      props = env_file_properties
        .deep_merge(global_properties)
        .deep_merge(class_properties)
        .deep_merge(function_properties)
      finalize_properties!(props)
    end

    # Add properties managed by Jets.
    def finalize_properties!(props)
      handler = full_handler(props)
      runtime = get_runtime(props)
      props.merge!(
        "FunctionName" => map.function_name,
        "Handler" => handler,
        "Runtime" => runtime,
      )
    end

    def get_runtime(props)
      props["Runtime"] || default_runtime
    end

    # Ensure that the handler path is normalized.
    def full_handler(props)
      if props["Handler"]
        map.handler_value(props["Handler"])
      else
        default_handler
      end
    end

    # Global properties example:
    # jets defaults are in jets/default/application.rb.
    # Your application's default config/application.rb then get used. Example:
    #
    #   Jets.application.configure do
    #     config.function = ActiveSupport::OrderedOptions.new
    #     config.function.timeout = 10
    #     config.function.runtime = "nodejs8.10"
    #     config.function.memory_size = 1536
    #   end
    def global_properties
      baseline = {
        Code: {
          S3Bucket: {Ref: "S3Bucket"}, # from child stack
          S3Key: map.code_s3_key
        },
        Role: { Ref: "IamRole" },
        Environment: { Variables: map.environment },
      }.deep_stringify_keys

      app_config_props = Jets.application.config.function.to_h
      app_config_props = Jets::Pascalize.pascalize(app_config_props.deep_stringify_keys)

      baseline.deep_merge(app_config_props)
    end

    # Class properties example:
    #
    #   class PostsController < ApplicationController
    #     class_timeout 22
    #     ...
    #   end
    #
    # Also handles iam policy override at the class level. Example:
    #
    #   class_iam_policy("logs:*")
    #
    def class_properties
      # klass is PostsController, HardJob, GameRule, Hello or HelloFunction
      klass = Jets::Klass.from_task(@task)
      class_properties = klass.class_properties
      if klass.build_class_iam?
        map = Jets::Cfn::TemplateMappers::IamPolicy::ClassPolicyMapper.new(klass)
        class_properties[:Role] = "!GetAtt #{map.logical_id}.Arn"
      end
      Jets::Pascalize.pascalize(class_properties.deep_stringify_keys)
    end

    # Function properties example:
    #
    # class PostsController < ApplicationController
    #   timeout 18
    #   def index
    #     ...
    #   end
    #
    # Also handles iam policy override at the function level. Example:
    #
    #   iam_policy("ec2:*")
    #   def new
    #     render json: params.merge(action: "new")
    #   end
    #
    def function_properties
      properties = @task.properties
      if @task.build_function_iam?
        map = Jets::Cfn::TemplateMappers::IamPolicy::FunctionPolicyMapper.new(@task)
        properties[:Role] = "!GetAtt #{map.logical_id}.Arn"
      end
      Jets::Pascalize.pascalize(properties.deep_stringify_keys)
    end

    def env_file_properties
      env_vars = Jets::Dotenv.load!(true)
      Jets::Pascalize.pascalize(environment: { variables: env_vars })
    end
  end
end

