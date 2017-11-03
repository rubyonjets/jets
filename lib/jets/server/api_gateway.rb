class Jets::Server
  class ApiGateway
    def self.call(env)
      route = RouteMatcher.new(env).find_route
      if route
        proxy = LambdaAwsProxy.new(route, env)
        triplet = proxy.response
      else
        # TODO: print out jets routes in development mode
        [404, {'Content-Type' => 'text/html'}, ["Route not found.  TODO: print out jets routes in development mode.\n"]]
      end
    end
  end
end
