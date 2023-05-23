# Detects route to changes
class Jets::Cfn::Resource::ApiGateway::RestApi::Routes::Change
  class To < Base
    def changed?
      deployed_routes.each do |deployed_route|
        next if deployed_route.engine   # skip engine routes
        next if deployed_route.internal # skip internal routes

        new_route = find_comparable_route(deployed_route)
        next unless new_route

        if new_route.to != deployed_route.to
          # change in already deployed route has been detected, requires bluegreen deploy
          return true
        end
      end
      false # Reaching here means no routes have been changed in a way that requires a bluegreen deploy
    end

    # Find a route that has the same path and method. This is a comparable route
    # Then we will compare the to or controller action to see if an already
    # deployed route has been changed.
    def find_comparable_route(deployed_route)
      new_routes.find do |new_route|
        new_route.path == deployed_route.path &&
        new_route.http_method == deployed_route.http_method
      end
    end
  end
end
