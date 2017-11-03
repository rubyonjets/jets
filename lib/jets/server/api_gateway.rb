require 'kramdown'

class Jets::Server
  class ApiGateway
    def self.call(env)
      route = RouteMatcher.new(env).find_route
      if route
        proxy = LambdaAwsProxy.new(route, env)
        triplet = proxy.response
      else
        # TODO: print out jets routes in development mode
        [404, {'Content-Type' => 'text/html'}, [routes_error_message(env)]]
      end
    end

    def self.routes_error_message(env)
      "<h2>404 Error: Route #{env['PATH_INFO'].sub('/','')} not found</h2>" \
      "<p>Here are the routes defined in your application.</p>" \
      "#{routes_table}.\n"
    end

    def self.routes_table
      routes = Jets::Router.routes
      text = "Verb | Path | Controller#action\n"
      text << "--- | --- | ---\n"
      routes.each do |route|
        text << "#{route.method} | #{route.path} | #{route.to}\n"
      end
      Kramdown::Document.new(text).to_html
    end
  end
end
