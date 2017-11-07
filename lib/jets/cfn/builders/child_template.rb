class Jets::Cfn::Builders
  class ChildTemplate
    include Interface

    # The child_class is can be a controller or a job
    def initialize(child_class)
      @child_class = child_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # template_path is an interface method for Interface module
    def template_path
      Jets::Naming.template_path(@child_class)
    end

    def add_common_parameters
      add_parameter("IamRole", Description: "Iam Role that Lambda function uses.")
      add_parameter("S3Bucket", Description: "S3 Bucket for source code.")
    end

    def add_functions
      @child_class.lambda_functions.each do |name|
        add_function(name)
      end
    end

    def add_function(name)
      map = Jets::Cfn::Mappers::LambdaFunctionMapper.new(@child_class, name)

      add_resource(map.logical_id, "AWS::Lambda::Function",
        Code: {
          S3Bucket: {Ref: "S3Bucket"}, # from child stack
          S3Key: map.code_s3_key
        },
        FunctionName: map.function_name,
        Handler: map.handler,
        Role: { Ref: "IamRole" },
        MemorySize: Jets.config.memory_size,
        Runtime: Jets.config.runtime,
        Timeout: Jets.config.timeout,
        Environment: { Variables: map.environment },
      )
    end
  end
end
