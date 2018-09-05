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

      path = route.path

      if actual_path == path
        # regular string match detection
        return true # exact route matches are highest precedence
      end

      # Check path for route capture and wildcard matches:
      # A colon (:) means the variable has a variable
      if path.include?(':') # 2nd highest precedence
        capture_detection(path, actual_path) # early return true or false
      # A star (*) means the variable has a glob
      elsif path.include?('*') # lowest precedence
        proxy_detection(path, actual_path) # early return true or false
      else
        false # reach here, means no route matched
      end
    end

    # catchall/globbing/wildcard/proxy routes. Examples:
    #
    #    get "files/*path", to: "files#show"
    #    get "others/*rest", to: "others#show"
    #    get "*catchall", to: "public_files#show" # last catchall route for Jets
    #
    def proxy_detection(route_path, actual_path)
      # drop the proxy_segment
      leading_path = route_path.split('/')[0..-2].join('/')

      # get "*catchall", to: "public_files#show"
      if leading_path.empty? # This is the last catchall route "*catchall"
        return true # always return true here because the entire path
        # will always match
      end

      # Other types of wildcard route:
      #
      #    get "files/*path", to: "files#show"
      #    get "others/*rest", to: "others#show"
      unless leading_path.ends_with?('/')
        # Ensure trailing slash to make pattern matching stricter
        leading_path = "#{leading_path}/"
      end

      pattern = "^#{leading_path}"
      regexp = Regexp.new(pattern)
      !!regexp.match(actual_path) # could be true or false
    end

    def capture_detection(route_path, actual_path)
      # changes path to a string used for a regexp
      # posts/:id/edit => posts\/(.*)\/edit

      regexp_string = route_path.split('/').map do |s|
                        s.include?(':') ? Jets::Route::CAPTURE_REGEX : s
                      end.join('\/')
      # make sure beginning and end of the string matches
      regexp_string = "^#{regexp_string}$"

      regexp = Regexp.new(regexp_string)
      !!regexp.match(actual_path) # could be true or false
    end

    def router
      return @router if @router
      @router = Jets.application.routes
    end
  end
end
