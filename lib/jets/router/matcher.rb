class Jets::Router
  class Matcher
    def initialize(path, method)
      @path = path.sub(/^\//,'')
      @method = method.to_s.upcase
    end

    def match?(route)
      # Immediately stop checking when the request method: GET, POST, ANY, etc
      # doesnt match.

      return false if method != route.method && route.method != "ANY"

      route_path = route.path

      if path == route_path
        # regular string match detection
        return true # exact route matches are highest precedence
      end

      # Check path for route capture and wildcard matches:
      # A colon (:) means the variable has a variable
      if route_path.include?(':') # 2nd highest precedence
        capture_detection(route_path, path) # early return true or false
      # A star (*) means the variable has a glob
      elsif route_path.include?('*') # lowest precedence
        proxy_detection(route_path, path) # early return true or false
      else
        false # reach here, means no route matched
      end
    end

  private

    attr_reader :path, :method

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
                        s.include?(':') ? Jets::Router::Route::CAPTURE_REGEX : s
                      end.join('\/')
      # make sure beginning and end of the string matches
      regexp_string = "^#{regexp_string}$"

      regexp = Regexp.new(regexp_string)

      !!regexp.match(actual_path) # could be true or false
    end
  end
end
