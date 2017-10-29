class Jets::Cfn::Builder
  class GatewayMethodMapper
    def initialize(route)
      @route = route # {:to=>"posts#index", :path=>"posts", :method=>:get}
    end

    # Returns: "ApiGatewayResourcePostsController"
    def gateway_resource_logical_id
      "ApiGatewayResource#{path_logical_id}"
    end

    def gateway_method_logical_id
      "ApiGatewayMethod#{controller_action}"
    end

    def lambda_function_logical_id
      "#{controller_action}LambdaFunction"
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

    def path_logical_id
      @route.path.gsub('/','_').gsub(':','').camelize
    end
  end
end