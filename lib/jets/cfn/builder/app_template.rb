class Jets::Cfn::Builder
  class AppTemplate
    include Helpers

    def initialize(controller_class)
      @controller_class = controller_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      add_parameters
      add_functions
      # add_routes
    end

    # template_path is an interface method
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
      names = Jets::Naming.new(@controller_class, name) # TODO: clean this up and remove Naming from here
      map = LambdaFunctionMapper.new(@controller_class, name)

      add_resource(map.lambda_function_logical_id, "AWS::Lambda::Function",
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

      scoped_routes.each do |route|
         # {:to=>"posts#index", :path=>"posts", :method=>:get}
        map = GatewayMethodMapper.new(route)
        # IE: map.gateway_method_logical_id: ApiGatewayMethodPostsControllerIndex
        add_resource(map.gateway_method_logical_id, "AWS::ApiGateway::Method",
          HttpMethod: route.method.upcase,
          RequestParameters: {},
          ResourceId: "!Ref #{map.gateway_resource_logical_id}", # This is crazy, it will map to a different APIGatewayResource depending on the 1. path itself 2. method, the APIGatewayResource's will be in another template and passed in as nested parameter
          # This is a problem because CloudFormation has a limit of 60 parameters
          RestApiId: "!Ref ApiGatewayRestApi",
          AuthorizationType: "NONE",
          Integration: {
            IntegrationHttpMethod: route.method.upcase,
            Type: "AWS_PROXY",
            Uri: {
              "Fn:Join": ["", [
                "arn:aws:apigateway:",
                {Ref:"AWS::Region"},
                ":lambda:path/2015-03-31/functions/",
                {"Fn:GetAtt": [map.lambda_function_logical_id, "Arn"]}, # IE: PostsControllerIndexLambdaFunction
                "/invocations"]]
            }
          },
          MethodResponses:[]
        )
      end
    end

    # "arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:123412341234:function:My_Function/invocations"
    def scoped_routes
      @routes ||= Jets::Build::RoutesBuilder.routes.select do |route|
        route.controller_name == @controller_class.to_s
      end
    end
  end
end
