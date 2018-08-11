require 'kramdown'

class Jets::Server
  class ApiGateway
    def self.call(env)
      Jets.boot
      route = RouteMatcher.new(env).find_route
      if route
        proxy = LambdaAwsProxy.new(route, env)
        triplet = proxy.response
      else
        [404, {'Content-Type' => 'text/html'}, [routes_error_message(env)]]
      end
    end

    def self.routes_error_message(env)
      message = "<h2>404 Error: Route #{env['PATH_INFO'].sub('/','')} not found</h2>"
      if Jets.env != "production"
        message << "<p>Here are the routes defined in your application:</p>"
        message << "#{routes_table}"
      end
      message
    end

    # Show pretty route table for user to help with debugging in non-production mode
    def self.routes_table
      routes = Jets::Router.routes

      return "Your routes table is empty." if routes.empty?

      text = "Verb | Path | Controller#action\n"
      text << "--- | --- | ---\n"
      routes.each do |route|
        text << "#{route.method} | #{route.path} | #{route.to}\n"
      end
      Kramdown::Document.new(text).to_html
    end
  end
end
