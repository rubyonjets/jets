require "rack/utils"

# Special renderer.  All the other renderers lead here
module Jets::Controller::Rendering
  class RackRenderer
    delegate :request, :event, :headers, to: :controller
    attr_reader :controller
    def initialize(controller, options={})
      @controller = controller
      @options = options
    end

    # Example response:
    #
    #   [200, {"my-header" = > "value" }, "my body" ]
    #
    # Returns rack triplet
    def render
      # we do some normalization here
      status = normalize_status_code(@options[:status])

      base64 = normalized_base64_option(@options)

      headers = @options[:headers] || {}
      headers = cors_headers.merge(headers)
      set_content_type!(status, headers)
      # x-jets-base64 to convert this Rack triplet to a API Gateway hash structure later
      headers["x-jets-base64"] = base64 ? 'yes' : 'no' # headers values must be Strings

      # Rails rendering does heavy lifting
      if drop_content_info?(status)
        body = StringIO.new
      else
        renderer = ActionController::Base.renderer.new(renderer_options)
        body = renderer.render(render_options)
        body = StringIO.new(body)
      end

      [status, headers, body] # triplet
    end

    # Example: posts/index
    def default_template_name
      "#{template_namespace}/#{@controller.meth}"
    end

    # PostsController => "posts" is the namespace
    def template_namespace
      @controller.class.to_s.sub('Controller','').underscore.pluralize
    end

    # default options:
    #   https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/renderer.rb#L41-L47
    def renderer_options
      options = {
        # script_name: "", # unfortunately doesnt seem to effect relative_url_root like desired
        # input: ""
      }

      origin = headers["origin"]
      if origin
        uri = URI.parse(origin)
        options[:https] = uri.scheme == "https"
      end

      # Important to not use rack_headers as local variable instead of headers.
      # headers is a method that gets deleted to controller.headers and using it
      # seems to cause issues.
      rack_headers = rackify_headers(headers)
      options.merge!(rack_headers)

      # Note @options[:method] uses @options vs options on purpose
      @options[:method] = event["httpMethod"].downcase if event["httpMethod"]
      options
    end

    # Takes headers and adds HTTP_ to front of the keys because that is what rack
    # does to the headers passed from a request. This seems to be the standard
    # when testing with curl and inspecting the headers in a Rack app.  Example:
    # https://gist.github.com/tongueroo/94f22f6c261c8999e4f4f776547e2ee3
    #
    # This is useful for:
    #
    #   ActionController::Base.renderer.new(renderer_options)
    #
    # renderer_options are rack normalized headers.
    #
    # Example input (from api gateway)
    #
    #   {"host"=>"localhost:8888",
    #   "user-agent"=>"curl/7.53.1",
    #   "accept"=>"*/*",
    #   "version"=>"HTTP/1.1",
    #   "x-amzn-trace-id"=>"Root=1-5bde5b19-61d0d4ab4659144f8f69e38f"}
    #
    # Example output:
    #
    #   {"HTTP_HOST"=>"localhost:8888",
    #   "HTTP_USER_AGENT"=>"curl/7.53.1",
    #   "HTTP_ACCEPT"=>"*/*",
    #   "HTTP_VERSION"=>"HTTP/1.1",
    #   "HTTP_X_AMZN_TRACE_ID"=>"Root=1-5bde5b19-61d0d4ab4659144f8f69e38f"}
    #
    def rackify_headers(headers)
      results = {}
      headers.each do |k,v|
        rack_key = 'HTTP_' + k.gsub('-','_').upcase
        results[rack_key] = v
      end
      results
    end

    def render_options
      # nomralize the template option
      template = @options[:template]
      if template and !template.include?('/')
        template = "#{template_namespace}/#{template}"
      end
      template ||= default_template_name
      # ready to override @options[:template]
      @options[:template] = template if @options[:template]

      render_options = {
        template: template, # weird: template needs to be set no matter because it
          # sets the name which is used in lookup_context.rb:209:in `normalize_name'
        layout: @options[:layout],
        assigns: controller_instance_variables,
      }
      types = %w[json inline plain file xml body action].map(&:to_sym)
      types.each do |type|
        render_options[type] = @options[type] if @options[type]
      end

      render_options
    end

    def controller_instance_variables
      instance_vars = @controller.instance_variables.inject({}) do |vars, v|
        k = v.to_s.sub(/^@/,'') # @var => var
        vars[k] = @controller.instance_variable_get(v)
        vars
      end
      instance_vars[:event] = event
      instance_vars
    end

  private
    # From jets/controller/response.rb
    def drop_content_info?(status)
      status.to_i / 100 == 1 or drop_body?(status)
    end

    DROP_BODY_RESPONSES = [204, 304]
    def drop_body?(status)
      DROP_BODY_RESPONSES.include?(status.to_i)
    end

    # maps:
    #   :continue => 100
    #   :success => 200
    #   etc
    def normalize_status_code(code)
      status_code = if code.is_a?(Symbol)
                      Rack::Utils::SYMBOL_TO_STATUS_CODE[code]
                    else
                      code
                    end
      (status_code || 200).to_s # API Gateway requires a string but rack is okay with either
    end

    def set_content_type!(status, headers)
      if drop_content_info?(status)
        headers.delete "Content-Length"
        headers.delete "Content-Type"
      else
        headers["Content-Type"] = @options[:content_type] ||
                                  headers['content-type'] || # Mega Mode (Rails)
                                  headers['Content-Type'] || # Just in case
                                  Jets::Controller::DEFAULT_CONTENT_TYPE
      end
    end

    def normalized_base64_option(options)
      base64 = @options[:base64] if options.key?(:base64)
      base64 = @options[:isBase64Encoded] if options.key?(:isBase64Encoded)
      base64
    end

    def cors_headers
      case Jets.config.cors
      when true
        {
          "Access-Control-Allow-Origin" => "*", # Required for CORS support to work
          "Access-Control-Allow-Credentials" => "true" # Required for cookies, authorization headers with HTTPS
        }
      when Hash
        Jets.config.cors # contains Hash with Access-Control-Allow-* values
      else
        {}
      end
    end

    class << self
      def setup!
        require "action_controller"
        require "jets/overrides/rails"

        # Load helpers
        # Assign local variable because scoe in the `:action_view do` changes
        app_helper_classes = find_app_helper_classes
        ActiveSupport.on_load :action_view do
          include ApplicationHelper # include first
          app_helper_classes.each do |helper_class|
            include helper_class
          end
        end

        ActionController::Base.append_view_path("#{Jets.root}app/views")

        setup_webpacker if Jets.webpacker?
      end

      # Does not include ApplicationHelper, will include ApplicationHelper explicitly first.
      def find_app_helper_classes
        klasses = []
        expression = "#{Jets.root}app/helpers/**/*"
        Dir.glob(expression).each do |path|
          next unless File.file?(path)
          class_name = path.sub("#{Jets.root}app/helpers/","").sub(/\.rb/,'')
          unless class_name == "application_helper"
            klasses << class_name.classify.constantize # autoload
          end
        end
        klasses
      end

      def setup_webpacker
        require 'webpacker'
        require 'webpacker/helper'

        ActiveSupport.on_load :action_controller do
          ActionController::Base.helper Webpacker::Helper
        end

        ActiveSupport.on_load :action_view do
          include Webpacker::Helper
        end
      end
    end
  end
end

Jets::Controller::Rendering::RackRenderer.setup!
