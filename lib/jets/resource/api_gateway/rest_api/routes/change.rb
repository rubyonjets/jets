# Detects route changes
class Jets::Resource::ApiGateway::RestApi::Routes
  class Change < Base
    def changed?
      deployed_routes.each do |deployed_route|
        new_route = find_comparable_route(deployed_route)
        if new_route && new_route.to != deployed_route.to
          # change in already deployed route has been detected, requires bluegreen deploy
          return true
        end
      end
      false # Reaching here means no routes have been changed in a way that requires a bluegreen deploy
    end

    # Build up deployed routes from the existing CloudFormation resources.
    def deployed_routes
      routes = []

      resources, position = [], true
      while position
        position = nil if position == true # start of loop
        resp = apigateway.get_resources(
          rest_api_id: rest_api_id,
          position: position,
        )
        resources += resp.items
        position = resp.position
      end

      resources.each do |resource|
        resource_methods = resource.resource_methods
        next if resource_methods.nil?

        resource_methods.each do |http_verb, resource_method|
          # puts "#{http_verb} #{resource.path} | resource.id #{resource.id}"
          # puts to(resource.id, http_verb)

          # Test changing config.cors and CloudFormation does an in-place update
          # on the resource. So no need to do bluegreen deployments for OPTIONS.
          next if http_verb == "OPTIONS"

          path = recreate_path(resource.path)
          method = http_verb.downcase.to_sym
          to = to(resource.id, http_verb)
          route = Jets::Route.new(path: path, method: method, to: to)
          routes << route
        end
      end
      routes
    end
    memoize :deployed_routes

    # Find a route that has the same path and method. This is a comparable route
    # Then we will compare the to or controller action to see if an already
    # deployed route has been changed.
    def find_comparable_route(deployed_route)
      new_routes.find do |new_route|
        new_route.path == deployed_route.path &&
        new_route.method == deployed_route.method
      end
    end

    def recreate_path(path)
      path = path.gsub(%r{^/},'')
      path = path.sub(/{(.*)\+}/, '*\1')
      path.sub(/{(.*)}/, ':\1')
    end

    def to(resource_id, http_method)
      uri = method_uri(resource_id, http_method)
      recreate_to(uri) unless uri.nil?
    end

    def method_uri(resource_id, http_method)
      resp = apigateway.get_method(
        rest_api_id: rest_api_id,
        resource_id: resource_id,
        http_method: http_method
      )
      resp.method_integration.uri
    end

    # Parses method uri and recreates a Route to argument.
    # So:
    #   "arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:112233445566:function:demo-test-posts_controller-new/invocations"
    # Returns:
    #   posts#new
    def recreate_to(method_uri)
      md = method_uri.match(/function:(.*)\//)
      function_name = md[1] # IE: demo-dev-posts_controller-new
      controller_action = function_name.sub("#{Jets.project_namespace}-", '')
      md = controller_action.match(/(.*)_controller-(.*)/)
      controller = md[1]
      controller = controller.gsub('-','/')
      action = md[2]
      "#{controller}##{action}" # IE: posts#new
    end

    # Duplicated in rest_api/change_detection.rb, base_path/role.rb, rest_api/routes.rb
    def rest_api_id
      stack_name = Jets::Naming.parent_stack_name
      return default unless stack_exists?(stack_name)

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first

      api_gateway_stack_arn = lookup(stack[:outputs], "ApiGateway")

      # resources = cfn.describe_stack_resources(stack_name: api_gateway_stack_arn).stack_resources
      stack = cfn.describe_stacks(stack_name: api_gateway_stack_arn).stacks.first
      lookup(stack[:outputs], "RestApi") # rest_api_id
    end
    memoize :rest_api_id
  end
end
