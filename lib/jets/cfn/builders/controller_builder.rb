# Implements:
#
#   compose
#   template_path
#
module Jets::Cfn::Builders
  class ControllerBuilder < BaseChildBuilder
    # compose is an interface method for Interface module
    def compose
      add_common_parameters
      add_api_gateway_parameters
      add_functions
      add_routes
      add_resources
    end

    def add_api_gateway_parameters
      return if Jets::Router.routes.empty?

      add_parameter("RestApi", Description: "RestApi")
      scoped_routes.each do |route|
        resource = Jets::Resource::ApiGateway::Resource.new(route.path)
        add_parameter(resource.logical_id, description: resource.desc)
        if route.authorizer
          add_parameter(route.authorizer_id, description: route.authorizer_metadata)
        end
      end

      if @app_class.authorizer
        add_parameter(@app_class.authorizer_id, description: @app_class.authorizer_metadata)
      end
    end

    def add_routes
      scoped_routes.each_with_index do |route, i|
        method = Jets::Resource::ApiGateway::Method.new(route)
        add_resource(method)
        add_resource(method.permission)
        add_resource(method.cors) if Jets.config.cors
      end
    end

    # routes scoped to this controller template.
    def scoped_routes
      @routes ||= Jets::Router.routes.select do |route|
        route.controller_name == @app_class.to_s
      end
    end
  end
end
