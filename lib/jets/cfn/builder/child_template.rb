class Jets::Cfn::Builder
  class ChildTemplate
    include Helpers

    def initialize(controller_class)
      @controller_class = controller_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # template_path is an interface method for Helpers module
    def template_path
      Jets::Naming.template_path(@controller_class)
    end

    def add_common_parameters
      add_parameter("IamRole", Description: "Iam Role that Lambda function uses.")
      add_parameter("S3Bucket", Description: "S3 Bucket for source code.")
    end

    def add_function(name)
      map = LambdaFunctionMapper.new(@controller_class, name)

      add_resource(map.lambda_function_logical_id, "AWS::Lambda::Function",
        Code: {
          S3Bucket: {Ref: "S3Bucket"}, # from child stack
          S3Key: map.code_s3_key
        },
        FunctionName: map.function_name,
        Handler: map.handler,
        Role: { Ref: "IamRole" },
        MemorySize: Jets::Config.memory_size,
        Runtime: Jets::Config.runtime,
        Timeout: Jets::Config.timeout
      )
    end
  end
end
