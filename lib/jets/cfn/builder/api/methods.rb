module Jets::Cfn::Builder::Api
  class Methods < Paged
    # interface method
    def compose
      return if routes.empty?
      add_api_methods
      add_api_gateway_parameters
    end

    # Resources Example (only showing keys we care about):
    #
    #   UpIndexGetApiMethod:
    #     Type: AWS::ApiGateway::Method
    #     Properties:
    #       ResourceId: !Ref UpApiResource
    #       RestApiId: !Ref RestApi
    #       Integration:
    #         Uri: !Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${UpControllerIndexLambdaFunction}/invocations
    #
    def add_api_methods
      routes.each_with_index do |route, i|
        method = Jets::Cfn::Resource::ApiGateway::Method.new(route)
        add_resource(method)
      end
    end

    def add_api_gateway_parameters
      api_methods = Jets::Cfn::Params::Api::Methods.new(template: @template)
      api_methods.params.each do |key, _|
        add_parameter(key)
      end
    end

    def routes
      ensure_one_apigw_method_proxy_routes!
      @items.map do |uid|
        Jets::Router.routes.find do |route|
          route.path == "/" && route.path == uid.split('|').last || # root route. any http method works
          "#{route.http_method}|#{route.path}" == uid # Match the method and path. IE: GET|posts/:id
        end
      end.compact
    end
    memoize :routes

    # Only add missing root route with one_apigw_method_for_all_routes setting.
    # Add the root route because that's how it works locally.
    # With one_apigw_method_for_all_routes, it all goes to one lambda function
    # and routing is determined by config/routes.rb
    def ensure_one_apigw_method_proxy_routes!
      return unless Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"

      # find before modifications
      catchall_route = Jets::Router.routes.find { |route| route.path =~ /^\/\*/ }
      root_route = Jets::Router.routes.find { |route| route.http_method == "GET" && route.path == "/" }

      # modifications
      unless catchall_route
        # Note: catchall to route does not matter. In one_apigw_method_for_all_routes mode it all goes to one lambda function
        # and then gets routed by config/routes.rb
        Jets::Router.routes << Jets::Router::Route.new(path: '/*catchall', http_method: 'ANY', to: 'jets/public#show')
      end
      if !root_route && catchall_route
        Jets::Router.routes << Jets::Router::Route.new(path: '/', http_method: 'GET', to: catchall_route.to)
      end
    end

    # template_path is an interface method
    def template_path
      Jets::Names.api_methods_template_path(@page_number)
    end
  end
end
