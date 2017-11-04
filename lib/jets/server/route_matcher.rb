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
      path_info = @env["PATH_INFO"].sub(/^\//,'') # remove beginning slash

      # First check the request method: GET, POST, ANY, etc
      return false if request_method != route.method and route.method != "ANY"

      # Then check path
      # If the route has a variable, use a regexp
      path = route.path
      if path.include?(':')
        # changes path to a string used for a regexp
        # posts/:id/edit => posts\/(.*)\/edit
        regexp_string = path.split('/').map do |s|
                          s.include?(':') ? "([a-zA-Z0-9_]*)" : s
                        end.join('\/')
        # make sure beginning and end of the string matches
        regexp_string = "^#{regexp_string}$"
      end

      if regexp_string
        regexp = Regexp.new(regexp_string)
        matched = !!regexp.match(path_info)
        return matched # could be true or false
      else
        # regular string match detection
        return false if path_info != route.path
      end

      true # if we get to here that route matches
    end

    def router
      return @router if @router
      @router = Jets::Router.new
      @router.evaluate
      @router
    end
  end
end
