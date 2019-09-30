# route = Jets::Router::Route.new(
#   path: "posts",
#   method: :get,
#   to: "posts#index",
# )
class Jets::Router
  class Route
    include Util
    include Authorizer

    CAPTURE_REGEX = "([^/]*)" # as string

    attr_reader :to, :as
    def initialize(options, scope=Scope.new)
      @options, @scope = options, scope
      @path = compute_path
      @to = compute_to
      @as = compute_as
    end

    def compute_path
      # Note: The @options[:prefix] is missing prefix and is not support via direct create_route.
      # This is because it can be added directly to the path. IE:
      #
      #     get "myprefix/posts", to: "posts#index"
      #
      # Also, this helps to keep the method creator logic more simple.
      #
      prefix = @scope.full_prefix
      prefix = account_scope(prefix)
      prefix = account_on(prefix)

      path = [prefix, @options[:path]].compact.join('/')
      path = path[1..-1] if path.starts_with?('/') # be more forgiving if / accidentally included
      path
    end

    def account_scope(prefix)
      return unless prefix
      return prefix unless @options[:from_scope]

      if @options[:singular_resource]
        prefix.split('/')[0..-2].join('/')
      else
        prefix.split('/')[0..-3].join('/')
      end
    end

    def account_on(prefix)
      # Tricky @scope.from == :resources since the account_scope already has accounted for it
      if @options[:on] == :collection && @scope.from == :resources
        prefix = prefix.split('/')[0..-2].join('/')
      end
      prefix == '' ? nil : prefix
    end

    def compute_to
      controller, action = get_controller_action(@options)
      mod = @options[:module] || @scope.full_module
      controller = [mod, controller].compact.join('/') # add module
      "#{controller}##{action}"
    end

    def compute_as
      return nil if @options[:as] == :disabled
      return unless @options[:method] == :get || @options[:root]

      controller, action = get_controller_action(@options)
      klass = if @options[:root]
        Jets::Router::MethodCreator::Root
      elsif %w[index edit show new].include?(action.to_s)
        class_name = "Jets::Router::MethodCreator::#{action.camelize}"
        class_name.constantize # Index, Show, Edit, New
      else
        Jets::Router::MethodCreator::Generic
      end

      klass.new(@options, @scope, controller).full_meth_name(nil)
    end

    # IE: standard: posts/:id/edit
    #     api_gateway: posts/{id}/edit
    def path(format=:jets)
      case format
      when :api_gateway
        api_gateway_format(@path)
      when :raw
        @path
      else # jets format
        ensure_jets_format(@path)
      end
    end

    def method
      @options[:method].to_s.upcase
    end

    def internal?
      !!@options[:internal]
    end

    def homepage?
      path == ''
    end

    # IE: PostsController
    def controller_name
      to.sub(/#.*/,'').camelize + "Controller"
    end

    # IE: index
    def action_name
      to.sub(/.*#/,'')
    end

    # Checks to see if the corresponding controller exists. Useful to validate routes
    # before deploying to CloudFormation and then rolling back.
    def valid?
      controller_class = begin
        controller_name.constantize
      rescue NameError
        return false
      end
      controller_class.lambda_functions.include?(action_name.to_sym)
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
        extract_parameters_capture(actual_path)
      elsif path.include?('*')
        extract_parameters_proxy(actual_path)
      else
        # Lambda AWS_PROXY sets null to the input request when there are no path parmeters
        nil
      end
    end

    def extract_parameters_proxy(actual_path)
      # changes path to a string used for a regexp
      # others/*proxy => others\/(.*)
      # nested/others/*proxy => nested/others\/(.*)
      if path.include?('/')
        leading_path = path.split('/')[0..-2].join('/') # drop last segment
        # leading_path: nested/others
        # capture everything after the leading_path as the value
        regexp = Regexp.new("#{leading_path}/(.*)")
        value = actual_path.match(regexp)[1]
      else
        value = actual_path
      end

      # the last segment without the '*' is the key
      proxy_segment = path.split('/').last # last segment is the proxy segment
      # proxy_segment: *proxy
      key = proxy_segment.sub('*','')

      { key => value }
    end

    def extract_parameters_capture(actual_path)
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

      values = regexp.match(actual_path).captures
      labels.map do |next_label|
        [next_label, values.delete_at(0)]
      end.to_h
    end

    def mount_class
      @options[:mount_class]
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
