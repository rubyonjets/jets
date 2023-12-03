module Jets::Router
  class Matcher
    extend Memoist

    attr_reader :routes
    def initialize(route_set=Jets.application.routes)
      @route_set = route_set
      @routes = route_set.ordered_routes
    end

    def request_path
      # Ensure leading slash
      # Be more forgiving and allow the request_path to be passed in without a leading slash.
      # Note: request PATH_INFO will always have a leading slash, but just in case.
      # This is also covered in specs.
      return unless @request_path
      @request_path.starts_with?('/') ? @request_path : "/#{@request_path}"
    end

    def request_method
      @request_method.to_s.upcase if @request_method
    end

    # Precedence:
    # 1. Routes with no captures get highest precedence: posts/new
    # 2. Then we consider the routes with captures: post/:id
    #
    # Within these 2 groups we consider the routes with the longest path first
    # since posts/:id and posts/:id/edit can both match.
    def find_by_request(request, request_method=nil)
      @request = request # @request is used to check constraints
      # Checking the request_method_from_hidden_method_field so that handler can find the right route
      # super early in the process. Otherwise lambda routes to the wrong controller action.
      @request_method = request_method || @request.request_method_from_hidden_method_field || @request.request_method.to_s.upcase
      @request_path = strip_format(@request.path)
      route = find_route
      match_constraints(route) if route
    end

    # Simpler version of find_by_request that does not check constraints.
    # Used by Jets::Controller::Middleware::Mimic and called super-early on.
    # Does not have access to @request object and path_params
    def find_by_env(env)
      @env = env
      @request_method = env["REQUEST_METHOD"] || "GET"
      @request_path = strip_format(env["PATH_INFO"])
      find_route
    end

    def find_by_controller_action(controller, action)
      controller = "#{controller.camelize}Controller"
      routes.find do |r|
        r.controller_name == controller.to_s &&
        r.action_name == action.to_s
      end
    end

    def find_route
      routes.each do |r|
        if r.engine
          route = find_engine_route(r)
          return route if route
        else
          found = match?(r)
          return r if found
        end
      end
      nil
    end

    def find_engine_route(route)
      return unless mount

      engine_matcher = self.class.new(route.engine.route_set)
      engine_route = if @request
                       engine_matcher.find_by_request(@request, @request_method)
                     else
                       engine_matcher.find_by_env(@env)
                     end
      # save original engine for route.extract_parameters later
      engine_route.original_engine = route.engine if engine_route
      engine_route
    end

    def mount
      EngineMount.find_by(request_path: request_path)
    end
    memoize :mount

    def strip_format(path)
      path.sub(/\..+$/, '') # Remove format from the end of the path
    end

    def match?(route)
      # Immediately stop checking when the request http_method: GET, POST, ANY, etc
      # doesnt match.
      return false if request_method != route.http_method && route.http_method != "ANY"

      route_path = strip_format(route.path)
      route_path = "#{mount.at}#{route_path}" if mount

      if request_path == route_path
        # regular string match detection
        return true # exact route matches are highest precedence
      end

      # Check path for route capture and wildcard matches:
      # A colon (:) means the variable has a variable
      if route_path.include?(':') # 2nd highest precedence
        capture_detection(route_path, request_path) # early return true or false
      # A star (*) means the variable has a glob
      elsif route_path.include?('*') # lowest precedence
        proxy_detection(route_path, request_path) # early return true or false
      else
        false # reach here, means no route matched
      end
    end

    def match_constraints(route)
      return unless route
      constraints_matches?(route) ? route : nil
    end

    # Matcher called in mimic.rb before mimic event is available
    # We need to extract the parameters from the possible matching route directly
    # since event is unavailable.
    def constraints_matches?(route)
      # Matcher is used super-early when request not yet available.
      # Cannot check constraints because we dont have the request object.
      # To build a request object, would need to build a mimic event and it's not yet available.
      return true if @request.nil?

      constraints = route.constraints
      return true if constraints.blank?

      if constraints.is_a?(Hash)
        parameters = route.extract_parameters(request_path) # extract directly
        constraints.any? do |key, value|
          key = key.to_s
          if value.is_a?(Regexp)
            value.match(parameters[key])
          else # String
            if parameters[key]
              value == parameters[key]
            elsif @request.respond_to?(key)
              value == @request.send(key)
            end
          end
        end
      elsif constraints.respond_to?(:call)
        constraints.call(@request)
      elsif constraints.respond_to?(:matches?)
        constraints.matches?(@request)
      end
    end

  private

    # catchall/globbing/wildcard/proxy routes. Examples:
    #
    #    get "files/*path", to: "files#show"
    #    get "others/*rest", to: "others#show"
    #    get "*catchall", to: "public_files#show" # last catchall route for Jets
    #
    def proxy_detection(route_path, request_path)
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

      !!regexp.match(request_path) # could be true or false
    end

    def capture_detection(route_path, request_path)
      # changes path to a string used for a regexp
      # posts/:id/edit => posts\/(.*)\/edit
      regexp_string = route_path.split('/').map do |s|
                        s.include?(':') ? Jets::Router::Route::CAPTURE_REGEX : s
                      end.join('\/')
      # make sure beginning and end of the string matches
      regexp_string = "^#{regexp_string}$"

      regexp = Regexp.new(regexp_string)

      !!regexp.match(request_path) # could be true or false
    end
  end
end
