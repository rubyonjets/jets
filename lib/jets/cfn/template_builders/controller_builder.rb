class Jets::Cfn::TemplateBuilders
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
        map = Jets::Cfn::TemplateMappers::GatewayResourceMapper.new(route.path)
        add_parameter(map.logical_id, Description: map.desc)
      end
    end

    def add_routes
      scoped_routes.each_with_index do |route, i|
        resource_route = Jets::Resource::Route.new(route)
        add_associated_resource(resource_route.resource)
        add_associated_resource(resource_route.resource.permission.attributes)
        # TODO: allow specifying specific CORs domains
        add_associated_resource(resource_route.resource.cors(route).attributes) if Jets.config.cors
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
