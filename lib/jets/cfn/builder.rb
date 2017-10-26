require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Builder
    def initialize(controller_class)
      @controller_class = controller_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    def compose!
      build_functions
    end

    def build_functions
      @controller_class.lambda_functions.each do |name|
        add_function(name)
      end
    end

    def add_function(name)
      namer = Namer.new(@controller_class, name)

      add_resource(namer.logical_id, "AWS::Lambda::Function",
        Code: {
          S3Bucket: {Ref: "S3Bucket"}, # from child stack
          S3Key: namer.s3_key
        },
        FunctionName: namer.function_name,
        Handler: namer.handler,
        Role: {
          "Fn::GetAtt": ["IamRoleLambdaExecution", "Arn"]
        },
        MemorySize: Jets::Project.memory_size,
        Runtime: Jets::Project.runtime,
        Timeout: Jets::Project.timeout
      )
    end

    def add_resource(logical_id, type, properties)
      @template[:Resources][logical_id] = {
        Type: type,
        Properties: properties
      }
    end

    def template
      @template
    end

    def text
      YAML.dump(@template.to_hash)
    end
  end
end
