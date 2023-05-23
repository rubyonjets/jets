module Jets::Controller::RackAdapter
  module Action
    extend ActiveSupport::Concern

    class_methods do
      def action(name)
        lambda do |env|
          route = find_first_route_for_action(name)
          env['PATH_INFO'] = route_path(route)
          controller = new({}, {}, name, env)
          controller.dispatch! # does not go through middleware stack
        end
      end

      # Find first route to be used for PATH_INFO.
      # This allows engine_delegate to work properly.
      def find_first_route_for_action(name)
        Jets::Router.routes.find do |r|
          route_controller_path, route_action_name = r.to.split('#')
          route_controller_path == controller_path && route_action_name == name.to_s
        end
      end

      def route_path(route)
        if route
          path = route.path
          path = "/#{path}" unless path.starts_with?('/')
        else
          path = "/#{controller_path}##{name} (action proc)"
        end
        path
      end
    end
  end
end
