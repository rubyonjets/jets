# route = Route.new(
#   path: "posts",
#   method: :get,
#   to: "posts#index",
# )
class Jets::Build
  class Route
    def initialize(options)
      @options = options
    end

    # IE: standard: posts/:id/edit
    #     api_gateway: posts/{id}/edit
    def path(api_gateway=false)
      if api_gateway
        api_gateway_format(@options[:path])
      else
        @options[:path]
      end
    end

    def method
      @options[:method].to_s.upcase
    end

    # IE: posts#index
    def to
      @options[:to]
    end

    # IE: PostsController
    def controller_name
      to.sub(/#.*/,'').camelize + "Controller"
    end

    # IE: index
    def action_name
      to.sub(/.*#/,'')
    end

    # Extracts the path parameters from the actual path
    # Only supports extracting 1 parameter. So:
    #
    #   actual_path: posts/tung/edit
    #   route.path: posts/:id/edit
    #
    # Returns:
    #    { id: "tung" }
    def extract_parameters(actual_path)
      if path.include?(':')
        # changes path to a string used for a regexp
        # posts/:id/edit => posts\/(.*)\/edit
        regexp_string = path.split('/').map do |s|
                          s.include?(':') ? "([a-zA-Z0-9_]*)" : s
                        end.join('\/')
        # make sure beginning and end of the string matches
        regexp_string = "^#{regexp_string}$"
        regexp = Regexp.new(regexp_string)
        value = regexp.match(actual_path)[1]

        key = path.split('/').find {|s| s.include?(':') } # :id
        key = key.sub(':','')
        {
          key => value
        }
      else
        # Lambda AWS_PROXY sets null to the input request when there are no path parmeters
        nil
      end
    end

  private
    def api_gateway_format(path)
      path.split('/').map {|s| transform_capture(s) }.join('/')
    end

    def transform_capture(text)
      if text.starts_with?(':')
        text = text.sub(':','')
        text = "{#{text}}"
      end
      text
    end
  end
end
