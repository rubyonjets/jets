class Jets::Resource::ApiGateway::RestApi::Routes::Change
  class Base
    extend Memoist
    include Jets::AwsServices

    def self.changed?
      new.changed?
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
          limit: 500, # default: 25 max: 500
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
          route = Jets::Router::Route.new(path: path, method: method, to: to)
          routes << route
        end
      end
      routes
    end
    memoize :deployed_routes

    def recreate_path(path)
      path = path.gsub(%r{^/},'')
      path = path.gsub(/{([^}]*)\+}/, '*\1')
      path.gsub(/{([^}]*)}/, ':\1')
    end

    def to(resource_id, http_method)
      uri = method_uri(resource_id, http_method)
      recreate_to(uri) unless uri.nil?
    end

    def method_uri(resource_id, http_method)
      # https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html
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
      function_arn = md[1] # IE: demo-dev-posts_controller-new
      controller, action = get_controller_action(function_arn)
      "#{controller}##{action}" # IE: posts#new
    end

    def get_controller_action(function_arn)
      if function_arn.include?('_controller-')
        controller_action_from_string(function_arn)
      else
        controller_action_from_api(function_arn)
      end
    end

    # TODO: If this hits the Lambda Rate limit, then list_functions also contains the Lambda
    # function description. So we can paginate through list_functions results and store
    # description from there if needed.
    # Dont think this will be needed though because controller_action_from_string gets called
    # most of the time. Also, user might be able to request their Lambda limit to be increased.
    def controller_action_from_api(function_arn)
      desc = lambda_function_description(function_arn)
      controller, action = desc.split('#')
      controller = controller.underscore.sub(/_controller$/,'')
      [controller, action]
    end

    def controller_action_from_string(function_arn)
      controller_action = function_arn.sub("#{Jets.project_namespace}-", '')
      md = controller_action.match(/(.*)_controller-(.*)/)
      controller = md[1]
      controller = controller.gsub('-','/')
      action = md[2]
      [controller, action]
    end

    def lambda_function_description(function_arn)
      resp = aws_lambda.get_function(function_name: function_arn)
      resp.configuration.description # contains full info: PostsController#index
    end

    # Duplicated in rest_api/change_detection.rb, base_path/role.rb, rest_api/routes.rb
    def rest_api_id
      stack_name = Jets::Naming.parent_stack_name
      return "RestApi" unless stack_exists?(stack_name)

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first

      api_gateway_stack_arn = lookup(stack[:outputs], "ApiGateway")

      # resources = cfn.describe_stack_resources(stack_name: api_gateway_stack_arn).stack_resources
      stack = cfn.describe_stacks(stack_name: api_gateway_stack_arn).stacks.first
      lookup(stack[:outputs], "RestApi") # rest_api_id
    end
    memoize :rest_api_id

    def new_routes
      Jets::Router.routes
    end
    memoize :new_routes
  end
end