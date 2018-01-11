# Jets::Cfn::TemplateBuilders does not stick to the TemplateBuilders::Interface.
# It builds the properties of a function. Usage:
#
#   builder = FunctionPropertiesBuilder.new(task)
#   buider.properties
#   buider.map.logical_id # to access Function's logical id
#
class Jets::Cfn::TemplateBuilders
  class FunctionPropertiesBuilder
    def initialize(task)
      @task = task
    end

    def map
      @map ||= Jets::Cfn::TemplateMappers::LambdaFunctionMapper.new(@task)
    end

    def properties
      env_file_properties
        .deep_merge(global_properties)
        .deep_merge(class_properties)
        .deep_merge(function_properties)
        .deep_merge(fixed_properties)
    end

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
      app_config_props = Pascalize.pascalize(app_config_props.deep_stringify_keys)

      baseline.deep_merge(app_config_props)
    end

    def class_properties
      # klass is PostsController, HardJob, Hello, or HelloFunction
      klass = Jets::Klass.from_task(@task)
      class_properties = klass.class_properties
      Pascalize.pascalize(class_properties.deep_stringify_keys)
    end

    def function_properties
      Pascalize.pascalize(@task.properties.deep_stringify_keys)
    end

    # Do not allow overriding of fixed properties. Changing properties will
    # likely cause issues with Jets.
    def fixed_properties
      {
        FunctionName: map.function_name,
        Handler: map.handler,
      }
    end

    def env_file_properties
      env_vars = Jets::Dotenv.load!
      Pascalize.pascalize(environment: { variables: env_vars })
    end
  end
end

