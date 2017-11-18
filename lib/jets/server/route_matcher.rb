class Jets::Server
  class RouteMatcher
    def initialize(env)
      @env = env
    end

    def find_route
      # Precedence:
      # 1. Routes with no captures get highest precedence: posts/new
      # 2. Then we consider the routes with captures: post/:id
      #
      # Within these 2 groups we consider the routes with the longest path first
      # since posts/:id and posts/:id/edit can both match.
      routes = router.ordered_routes
      route = routes.find do |route|
        route_found?(route)
      end
      route
    end

    def route_found?(route)
      request_method = @env["REQUEST_METHOD"]
      actual_path = @env["PATH_INFO"].sub(/^\//,'') # remove beginning slash

      # Immediately stop checking when the request method: GET, POST, ANY, etc
      # doesnt match.
      return false if request_method != route.method and route.method != "ANY"

      # Check path for route variables:
      # If the route has a variable, use a regexp
      path = route.path
      if path.include?('*')
        return proxy_detection(path, actual_path) # early return true or false
      elsif path.include?(':')
        return capture_detection(path, actual_path) # early return true or false
      else
        # regular string match detection
        return false if actual_path != path
      end

      true # if we get to here that route matches
    end

    def proxy_detection(route_path, actual_path)
      # drop the proxy_segment
      leading_path = route_path.split('/')[0..-2].join('/')
      unless leading_path.ends_with?('/') # ensure trailing slash
        # This makes the pattern match more strictly
        leading_path = "#{leading_path}/"
      end

      regexp = Regexp.new("^#{leading_path}")
      !!regexp.match(actual_path) # could be true or false
    end

    def capture_detection(route_path, actual_path)
      # changes path to a string used for a regexp
      # posts/:id/edit => posts\/(.*)\/edit
      regexp_string = route_path.split('/').map do |s|
                        s.include?(':') ? "([a-zA-Z0-9_]*)" : s
                      end.join('\/')
      # make sure beginning and end of the string matches
      regexp_string = "^#{regexp_string}$"

      regexp = Regexp.new(regexp_string)
      !!regexp.match(actual_path) # could be true or false
    end

    def router
      return @router if @router
      @router = Jets::Router.new
      @router.evaluate
      @router
    end
  end
end
