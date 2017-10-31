class Jets::Cfn::Builder
  class ControllerTemplate < ChildTemplate
    # compose is an interface method for Helpers module
    def compose
      add_common_parameters
      add_api_gateway_parameters
      add_functions
      add_routes
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
