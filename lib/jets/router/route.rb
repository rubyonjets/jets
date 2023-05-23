# route = Jets::Router::Route.new(
#   path: "posts",
#   http_method: :get,
#   to: "posts#index",
# )
module Jets::Router
  class Route
    extend Memoist
    include Compat
    include AfterInitialize
    include As
    include Authorizer
    include Path
    include Util

    CAPTURE_REGEX = "([^/]*)" # as string

    attr_reader :options, :scope, :info, :defaults
    attr_accessor :original_engine
    def initialize(options, scope=Scope.new)
      @options = options
      @scope = scope
      @info = Info.new(@options, @scope) # @info.action and @info.controller
      after_initialize
      @path_names = {}
    end

    def to
      engine || "#{@info.controller}##{@info.action}" # IE: posts#index
    end

    def engine
      @options[:engine]
    end
    alias rack_app engine

    def engine?
      !!engine
    end

    def endpoint
      engine.to_s if engine
    end

    def resolved_defaults
      defaults = @options[:defaults] || {}
      @scope.resolved_defaults.merge(defaults)
    end

    def http_method
      @options[:http_method].to_s.upcase
    end

    def constraints
      @options[:constraints] || @scope.resolved_constraints
    end

    def internal?
      !!@options[:internal]
    end

    def homepage?
      path == '/'
    end

    # IE: PostsController
    # IE: index
    delegate :action, :controller, :is_collection?, :is_member?, to: :@info
    alias action_name action

    # IE: PostsController
    # Different from @info.action
    def controller_name
      "#{controller.camelize}Controller" if controller
    end

    # Checks to see if the corresponding controller exists. Useful to validate routes
    # before deploying to CloudFormation and then rolling back.
    def valid?
      controller_class = begin
        controller_name.constantize
      rescue NameError => e
        return false
      end
      controller_class.lambda_functions.include?(action_name.to_sym)
    end

    # For Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
    # Need to build the pathParameters for the API Gateway event.
    def rebuild_path_parameters(event)
      extracted = extract_parameters(event["path"])
      if extracted
        params = event["pathParameters"] || {}
        params.merge(extracted)
      else
        event["pathParameters"] # pass through
      end
    end

    # Extracts the path parameters from the actual path
    # Only supports extracting 1 parameter. So:
    #
    #   request_path: posts/tung/edit
    #   route.path: posts/:id/edit
    #
    # Returns:
    #    { id: "tung" }
    def extract_parameters(request_path)
      request_path = "/#{request_path}" unless request_path.starts_with?('/') # be more forgiving if / accidentally not included
      request_path = remove_engine_mount_at_path(request_path)
      if path.include?(':')
        extract_parameters_capture(request_path)
      elsif path.include?('*')
        extract_parameters_proxy(request_path)
      else
        # Lambda AWS_PROXY sets null to the input request when there are no path parmeters
        nil
      end
    end

    def remove_engine_mount_at_path(request_path)
      return request_path unless original_engine

      mount = Jets::Router::EngineMount.find_by(engine: original_engine)
      return request_path unless mount

      request_path.sub(mount.at, '')
    end

    def extract_parameters_proxy(request_path)
      # changes path to a string used for a regexp
      # others/*proxy => others\/(.*)
      # nested/others/*proxy => nested/others\/(.*)
      if path.include?('/')
        leading_path = path.split('/')[0..-2].join('/') # drop last segment
        # leading_path: nested/others
        # capture everything after the leading_path as the value
        regexp = Regexp.new("#{leading_path}/(.*)")
        value = request_path.match(regexp)[1]
      else
        value = request_path
      end

      # the last segment without the '*' is the key
      proxy_segment = path.split('/').last # last segment is the proxy segment
      # proxy_segment: *proxy
      key = proxy_segment.sub('*','')

      { key => value }
    end

    def extract_parameters_capture(request_path)
      # changes path to a string used for a regexp
      # posts/:id/edit => posts\/(.*)\/edit
      labels = []
      regexp_string = path.split('/').map do |s|
                        if s.start_with?(':')
                          labels << s.delete_prefix(':')
                          CAPTURE_REGEX
                        else
                          s
                        end
                      end.join('\/')
      # make sure beginning and end of the string matches
      regexp_string = "^#{regexp_string}$"
      regexp = Regexp.new(regexp_string)

      values = regexp.match(request_path).captures
      labels.map do |next_label|
        [next_label, values.delete_at(0)]
      end.to_h
    end

    # Prevents infinite loop when calling route.to_json for state.save("routes", ...)
    def as_json(options= nil)
      data = {
        path: path,
        http_method: http_method,
        to: to,
      }
      data[:engine] = engine if engine
      data[:internal] = internal if internal
      data
    end

    # To keep "self #{self}" more concise and helpful
    # Use "self #{self.inspect}" more verbose info
    def to_s
      "#<Jets::Router::Route:#{object_id} @options=#{@options}>"
    end

    # Old notes:
    # For Grape apps, calling ActiveSupport to_json on a Grape class used to cause an infinite loop.
    # Believe Grape fixed this issue. A GrapeApp.to_json now produces a string.
    # No longer need to coerce to a string and back to a class.
    #
    # This is important because Sprocket::Environment.new cannot be coerced into a string or mounting wont work.
    # This is used in sprockets-jets/lib/sprockets/jets/engine.rb
    #
    # Related PR: smarter apigw routes paging calculation #635
    # https://github.com/boltops-tools/jets/pull/635
    # Debugging notes: https://gist.github.com/tongueroo/c9baa7e98d5ad68bbdd770fde4651963
    def mount_class
      @options[:mount_class]
    end

    # For jets routes help table of routes
    def mount_class_name
      return unless mount_class
      mount_class.class == Class ? mount_class : "#{mount_class.class}.new"
    end

  private
    def ensure_jets_format(path)
      path.split('/').map do |s|
        if s =~ /^\{/ and s =~ /\+\}$/
          s.sub(/^\{/, '*').sub(/\+\}$/,'') # {proxy+} => *proxy
        elsif s =~ /^\{/ and s =~ /\}$/
          s.sub('{',':').sub(/\}$/,'') # {id} => :id
        else
          s
        end
      end.join('/')
    end

    def api_gateway_format(path)
      path.split('/')
        .map {|s| transform_capture(s) }
        .map {|s| transform_proxy(s) }
        .join('/')
    end

    def transform_capture(text)
      if text.starts_with?(':')
        text = text.sub(':','')
        text = "{#{text}}"
      end
      text
    end

    def transform_proxy(text)
      if text.starts_with?('*')
        text = text.sub('*','')
        text = "{#{text}+}"
      end
      text
    end
  end
end
