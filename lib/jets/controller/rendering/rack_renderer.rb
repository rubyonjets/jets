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
      set_content_type!(status, headers)
      # x-jets-base64 to convert this Rack triplet to a API Gateway hash structure later
      headers["x-jets-base64"] = base64 ? 'yes' : 'no' # headers values must be Strings

      if drop_content_info?(status)
        body = StringIO.new
      else
        # Rails rendering does heavy lifting
        # _prefixes provided by jets/overrides/rails/action_controller.rb
        ActionController::Base._prefixes = @controller.controller_paths
        renderer = ActionController::Base.renderer.new(renderer_options)
        clear_view_cache
        body = renderer.render(render_options)
        body = StringIO.new(body)
      end

      [status, headers, body] # triplet
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

      # This is how we pass parameters to actionpack. IE: params to the view.
      # This is because renderer_options is actually the env that is passed to the rack request.
      options.merge!("action_dispatch.request.path_parameters" => @controller.path_parameters)
      options.merge!("action_dispatch.request.query_parameters" => @controller.query_parameters)
      options.merge!("action_dispatch.request.request_parameters" => @controller.request_parameters)
      options
    end

    def render_options
      # normalize the template option
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
        # prefixes: ["posts"],
      }
      types = %w[json inline plain file xml body action].map(&:to_sym)
      types.each do |type|
        render_options[type] = @options[type] if @options[type]
      end

      render_options
    end

    # Example: posts/index
    def default_template_name
      "#{template_namespace}/#{@controller.meth}"
    end

    # PostsController => "posts" is the namespace
    def template_namespace
      @controller.class.to_s.sub('Controller','').underscore
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

    # Pass controller instance variables from jets-based controller to ActionView scope
    def controller_instance_variables
      instance_vars = @controller.instance_variables.inject({}) do |vars, v|
        k = v.to_s.sub(/^@/,'') # @var => var
        vars[k] = @controller.instance_variable_get(v)
        vars
      end
      instance_vars[:event] = event
      # jets internal variables
      # So ActionView has access back to the jets controller
      instance_vars[:_jets] = { controller: @controller }
      instance_vars
    end

    def clear_view_cache
      ActionView::LookupContext::DetailsKey.clear if Jets.env.development?
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

      # API Gateway requires status to be String but local rack is okay with either
      # Note, ELB though requires status to be an Integer. We'll later in rack/adapter.rb
      # adjust status to an Integer if request is coming from an ELB.
      (status_code || 200).to_s
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

    class << self
      def setup!
        require "action_controller"
        require "jets/overrides/rails"

        # Load helpers
        # Assign local variable because scope in the `:action_view do` block changes
        app_helper_classes = find_app_helper_classes
        ActiveSupport.on_load :action_view do
          include Jets::Router::Helpers # internal routes helpers
          include ApplicationHelper  # include first
          app_helper_classes.each do |helper_class|
            include helper_class
          end
        end

        ActionController::Base.append_view_path("#{Jets.root}/app/views")

        setup_webpacker if Jets.webpacker?
      end

      # Does not include ApplicationHelper, will include ApplicationHelper explicitly first.
      def find_app_helper_classes
        internal_path = File.expand_path("../../internal", File.dirname(__FILE__))
        internal_classes = find_app_helper_classes_from(internal_path)
        app_classes = find_app_helper_classes_from(Jets.root)
        (internal_classes + app_classes).uniq
      end

      def find_app_helper_classes_from(project_root)
        klasses = []
        expression = "#{project_root}/app/helpers/**/*"
        Dir.glob(expression).each do |path|
          next unless File.file?(path)
          class_name = path.sub("#{project_root}/app/helpers/","").sub(/\.rb/,'')

          unless class_name == "application_helper"
            klasses << class_name.camelize.constantize # autoload
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
