class Jets::Cfn::Builder
  class AppStack
    include Helpers

    def initialize(controller_class)
      @controller_class = controller_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    def compose
      add_parameters
      add_functions
    end

    def template_path
      Jets::Cfn::Namer.template_path(@controller_class)
    end

    def add_parameters
      add_parameter("IamRole", Description: "Iam Role that Lambda function uses.")
      add_parameter("S3Bucket", Description: "S3 Bucket for source code.")
    end

    def add_functions
      @controller_class.lambda_functions.each do |name|
        add_function(name)
      end
    end

    def add_function(name)
      namer = Jets::Cfn::Namer.new(@controller_class, name)

      add_resource(namer.logical_id, "AWS::Lambda::Function",
        Code: {
          S3Bucket: {Ref: "S3Bucket"}, # from child stack
          S3Key: namer.code_s3_key
        },
        FunctionName: namer.function_name,
        Handler: namer.handler,
        Role: { Ref: "IamRole" },
        MemorySize: Jets::Project.memory_size,
        Runtime: Jets::Project.runtime,
        Timeout: 10 #Jets::Project.timeout
      )
    end
  end
end
