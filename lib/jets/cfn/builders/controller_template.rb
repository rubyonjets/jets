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
        add_parameter(map.logical_id, Description: map.path)
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
        add_route(route, map)
        add_cors(map)
        add_permission(map)
      end
    end

    def add_route(route, map)
      # AWS::ApiGateway::Method
      # Example map.logical_id: ApiGatewayMethodPostsControllerIndex
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
    end

    def add_cors(map)
      # TODO: provide a way to allow specify CORs domains
      return unless Jets::Config.cors

      add_resource(map.cors_logical_id, "AWS::ApiGateway::Method",
        AuthorizationType: "NONE",
        HttpMethod: "OPTIONS",
        MethodResponses: [
          {
            StatusCode: "200",
            ResponseParameters: {
              "method.response.header.Access-Control-AllowOrigin" => true,
              "method.response.header.Access-Control-AllowHeaders" => true,
              "method.response.header.Access-Control-AllowMethods" => true,
              "method.response.header.Access-Control-AllowCredentials" => true
            },
            ResponseModels: {}
          }
        ],
        RequestParameters: {},
        Integration: {
          Type: "MOCK",
          RequestTemplates: {
            "application/json" => "{statusCode:200}"
          },
          IntegrationResponses: [
            {
              StatusCode: "200",
              ResponseParameters: {
                "method.response.header.Access-Control-AllowOrigin" => "'*'",
                "method.response.header.Access-Control-AllowHeaders" => "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
                "method.response.header.Access-Control-AllowMethods" => "'OPTIONS,GET'",
                "method.response.header.Access-Control-AllowCredentials" => "'false'"
              },
              ResponseTemplates: {"application/json" => ""}
            }
          ]
        },
        ResourceId: "!Ref #{map.gateway_resource_logical_id}",
        RestApiId: "!Ref ApiGatewayRestApi",
      )
    end

    def add_permission(map)
      # AWS::Lambda::Permission
      add_resource(map.permission_logical_id, "AWS::Lambda::Permission",
        FunctionName: "!GetAtt #{map.lambda_function_logical_id}.Arn",
        Action: "lambda:InvokeFunction",
        Principal: "apigateway.amazonaws.com",
        SourceArn: "!Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${ApiGatewayRestApi}/*/*"
      )
    end

    # routes scoped to this controller template.
    def scoped_routes
      @routes ||= Jets::Build::Router.routes.select do |route|
        route.controller_name == @controller_class.to_s
      end
    end
  end
end
