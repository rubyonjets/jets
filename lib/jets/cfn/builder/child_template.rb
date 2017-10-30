class Jets::Cfn::Builder
  class ChildTemplate
    include Helpers

    def initialize(controller_class)
      @controller_class = controller_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      add_parameters
      add_functions
      add_routes
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.template_path(@controller_class)
    end

    def add_parameters
      add_parameter("IamRole", Description: "Iam Role that Lambda function uses.")
      add_parameter("S3Bucket", Description: "S3 Bucket for source code.")
      add_api_gateway_parameters
    end

    def add_api_gateway_parameters
      puts "add_api_gateway_parameters"
      add_parameter("ApiGatewayRestApi", Description: "ApiGatewayRestApi")
      Jets::Build::RoutesBuilder.all_paths.each do |path|
        map = GatewayResourceMapper.new(path)
        add_parameter(map.gateway_resource_logical_id, Description: map.path)
      end
    end

    def add_functions
      @controller_class.lambda_functions.each do |name|
        add_function(name)
      end
    end

    def add_function(name)
      names = Jets::Naming.new(@controller_class, name) # TODO: child_template.rb add_function uses both Naming and LambdaFunctionMapper.  Decide on one.
      map = LambdaFunctionMapper.new(@controller_class, name)

      add_resource(map.lambda_function_logical_id, "AWS::Lambda::Function",
        Code: {
          S3Bucket: {Ref: "S3Bucket"}, # from child stack
          S3Key: names.code_s3_key
        },
        FunctionName: names.function_name,
        Handler: names.handler,
        Role: { Ref: "IamRole" },
        MemorySize: Jets::Config.memory_size,
        Runtime: Jets::Config.runtime,
        Timeout: 10 #Jets::Config.timeout
      )
    end

    def add_routes
      puts "ADDING ROUTES"

      scoped_routes.each_with_index do |route, i|
         # {:to=>"posts#index", :path=>"posts", :method=>:get}
        map = GatewayMethodMapper.new(route)
        # IE: map.gateway_method_logical_id: ApiGatewayMethodPostsControllerIndex
        add_resource(map.gateway_method_logical_id, "AWS::ApiGateway::Method",
          HttpMethod: route.method,
          RequestParameters: {},
          ResourceId: "!Ref #{map.gateway_resource_logical_id}",
          RestApiId: "!Ref ApiGatewayRestApi",
          AuthorizationType: "NONE",
          Integration: {
            IntegrationHttpMethod: route.method,
            Type: "AWS_PROXY",
            Uri: "!Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${#{map.lambda_function_logical_id}.Arn}/invocations"
          },
          MethodResponses:[]
        )

        add_resource(map.permission_logical_id, "AWS::Lambda::Permission",
          FunctionName: "!GetAtt #{map.lambda_function_logical_id}.Arn",
          Action: "lambda:InvokeFunction",
          Principal: "apigateway.amazonaws.com",
          SourceArn: "!Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${ApiGatewayRestApi}/*/*"

          # SourceArn: {
          #   "Fn::Join": ["", [
          #     "arn:aws:execute-api:",
          #     {Ref:"AWS::Region"},
          #     ":",
          #     {Ref:"AWS::AccountId"},
          #     ":",
          #     {Ref:"ApiGatewayRestApi"},
          #     "/*/*"
          #   ]]
          # }

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
