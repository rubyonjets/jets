class Jets::Cfn::TemplateBuilders
  class BaseChildBuilder
    include Interface

    # The app_class is can be a controller or a job class.
    # IE: PostsController, HardJob
    def initialize(app_class)
      @app_class = app_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # template_path is an interface method for Interface module
    def template_path
      Jets::Naming.template_path(@app_class)
    end

    def add_common_parameters
      add_parameter("IamRole", Description: "Iam Role that Lambda function uses.")
      add_parameter("S3Bucket", Description: "S3 Bucket for source code.")
    end

    def add_functions
      @app_class.tasks.each do |task|
        add_function(task)
      end
    end

    def add_function(task)
      map = Jets::Cfn::TemplateMappers::LambdaFunctionMapper.new(@app_class, task)
      properties = properties(map, task)
      add_resource(map.logical_id, "AWS::Lambda::Function", properties)
    end

    def properties(map, task)
      global_properties = {
        Code: {
          S3Bucket: {Ref: "S3Bucket"}, # from child stack
          S3Key: map.code_s3_key
        },
        Role: { Ref: "IamRole" },
        MemorySize: Jets.config.memory_size,
        Runtime: Jets.config.runtime,
        Timeout: Jets.config.timeout,
        Environment: { Variables: map.environment },
      }.deep_stringify_keys

      class_properties = task.class_name.constantize.class_properties
      class_properties = pascalize(class_properties.deep_stringify_keys)

      function_properties = pascalize(task.properties.deep_stringify_keys)

      # Do not allow overriding of fixed properties. Changing properties will
      # likely cause issues with Jets.
      fixed_properties = {
        FunctionName: map.function_name,
        Handler: map.handler,
      }

      global_properties
        .deep_merge(class_properties)
        .deep_merge(function_properties)
        .deep_merge(fixed_properties)
    end

  private
    # Specialized pascalize that will not pascalize keys under the
    # Variables part of the hash structure.
    # Based on: https://stackoverflow.com/questions/8706930/converting-nested-hash-keys-from-camelcase-to-snake-case-in-ruby
    def pascalize(value, parent_key=nil)
      case value
        when Array
          value.map { |v| pascalize(v) }
        when Hash
          initializer = value.map do |k, v|
            new_key = pascal_key(k, parent_key)
            [new_key, pascalize(v, new_key)]
          end
          Hash[initializer]
        else
          value
       end
    end

    def pascal_key(k, parent_key=nil)
      if parent_key == "Variables" # do not pascalize keys anything under Variables
        k
      else
        k = k.to_s.camelize
        k.slice(0,1).capitalize + k.slice(1..-1) # capitalize first letter only
      end
    end
  end
end
