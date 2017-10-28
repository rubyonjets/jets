class Jets::Cfn::Builder
  class AppTemplate
    include Helpers

    def initialize(controller_class)
      @controller_class = controller_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    def compose
      add_parameters
      add_functions
      add_routes
    end

    def template_path
      Jets::Naming.template_path(@controller_class)
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
      names = Jets::Naming.new(@controller_class, name)

      add_resource(names.logical_id, "AWS::Lambda::Function",
        Code: {
          S3Bucket: {Ref: "S3Bucket"}, # from child stack
          S3Key: names.code_s3_key
        },
        FunctionName: names.function_name,
        Handler: names.handler,
        Role: { Ref: "IamRole" },
        MemorySize: Jets::Project.memory_size,
        Runtime: Jets::Project.runtime,
        Timeout: 10 #Jets::Project.timeout
      )
    end

    def add_routes
      puts "ADDING ROUTES"
      routes.each do |route|
        pp route
      end
    end

    # "arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:123412341234:function:My_Function/invocations"
    def routes
      @routes ||= Jets::Build::RoutesBuilder.routes.select do |route|
        route.controller_name == @controller_class.to_s
      end
    end
  end
end
