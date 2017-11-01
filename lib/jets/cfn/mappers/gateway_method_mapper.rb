class Jets::Cfn::Mappers
  class GatewayMethodMapper
    def initialize(route)
      @route = route # {:to=>"posts#index", :path=>"posts", :method=>:get}
    end

    def logical_id
      "ApiGatewayMethod#{controller_action}"
    end

    # Example returns:
    #   ApiGatewayResourcePostsIdEdit or
    #   ApiGatewayResourcePostsId or
    #   ApiGatewayResourcePosts
    def gateway_resource_logical_id
      resource_map = GatewayResourceMapper.new(@route.path)
      resource_map.logical_id
    end

    def lambda_function_logical_id
      "#{controller_action}LambdaFunction"
    end

    def permission_logical_id
      "#{controller_action}PermissionApiGateway"
    end

    # Example: PostsControllerIndex
    def controller_action
      controller, action = @route.to.split('#')
      "#{controller}_controller_#{action}".camelize
    end

    def controller
      controller, action = @route.to.split('#')
      "#{controller}_controller".camelize
    end
  end
end
