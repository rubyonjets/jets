class Jets::Cfn::Builders
  class ControllerBuilder < BaseChildBuilder
    # compose is an interface method for Interface module
    def compose
      add_common_parameters
      add_api_gateway_parameters
      add_functions
      add_routes
    end

    def add_api_gateway_parameters
      return if Jets::Router.routes.empty?

      add_parameter("RestApi", Description: "RestApi")
      scoped_routes.each do |route|
        resource = Jets::Resource::ApiGateway::Resource.new(route.path)
        add_parameter(resource.logical_id, Description: resource.desc)
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
        route.controller_name == @app_klass.to_s
      end
    end
  end
end
