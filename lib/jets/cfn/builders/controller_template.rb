class Jets::Cfn::Builders
  class ControllerTemplate < ChildTemplate
    # compose is an interface method for Interface module
    def compose
      add_common_parameters
      add_api_gateway_parameters
      add_functions
      add_routes
    end

    def add_api_gateway_parameters
      add_parameter("ApiGatewayRestApi", Description: "ApiGatewayRestApi")
      Jets::Build::Router.all_paths.each do |path|
        map = Jets::Cfn::Mappers::GatewayResourceMapper.new(path)
        add_parameter(map.gateway_resource_logical_id, Description: map.path)
      end
    end

    def add_functions
      @controller_class.lambda_functions.each do |name|
        add_function(name)
      end
    end

    def add_routes
      scoped_routes.each_with_index do |route, i|
        map = Jets::Cfn::Mappers::GatewayMethodMapper.new(route)
        # IE: map.logical_id: ApiGatewayMethodPostsControllerIndex
        add_resource(map.logical_id, "AWS::ApiGateway::Method",
          HttpMethod: route.method,
          RequestParameters: {},
          ResourceId: "!Ref #{map.gateway_resource_logical_id}",
          RestApiId: "!Ref ApiGatewayRestApi",
          AuthorizationType: "NONE",
          Integration: {
            IntegrationHttpMethod: "POST",
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
        )
      end
    end

    # routes scoped to this controller template.
    def scoped_routes
      @routes ||= Jets::Build::Router.routes.select do |route|
        route.controller_name == @controller_class.to_s
      end
    end
  end
end
