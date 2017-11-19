module Jets::Controller::Renderers
  class TemplateRenderer < BaseRenderer
    def initialize(options={})
      super
      @event = options[:event] || {}
      @headers = @event[:headers] || {}
    end

    def render
      @options[:body] = @options[:plain]
      @options[:content_type] = "text/plain"
      render_aws_proxy(@options)
    end

    def render
      setup_action_controller # setup only when necessary

      # ActionController::Base.renderer does heavy lifting
      renderer = ActionController::Base.renderer.new(renderer_options)

      template = @options[:template]
      if template and !template.include?('/')
        template = "#{template_namespace}/#{template}"
      end
      template ||= default_template_name

      layout = @options[:layout]

      body = renderer.render(
        template: template,
        layout: layout,
        assigns: all_instance_variables)
      @options[:body] = body # important to set as it was originally nil

      render_aws_proxy(@options)
    end

    # Example: posts/index
    def default_template_name
      "#{template_namespace}/#{@options[:controller_action]}"
    end

    # PostsController => "posts" is the namespace
    def template_namespace
      @options[:controller_class].to_s.sub('Controller','').underscore.pluralize
    end

    # default options:
    #   https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/renderer.rb#L41-L47
    def renderer_options
      origin = @headers["origin"]
      if origin
        uri = URI.parse(origin)
        https = uri.scheme == "https"
      end
      options = {
        http_host: @headers["Host"],
        https: https,
        # script_name: "",
        # input: ""
      }
      @options[:method] = @event["httpMethod"].downcase if @event["httpMethod"]
      options
    end

    def all_instance_variables
      instance_variables.inject({}) do |vars, v|
        k = v.to_s.sub(/^@/,'') # @event => event
        vars[k] = instance_variable_get(v)
        vars
      end
    end

    def setup_action_controller
      require "action_controller"
      require "jets/rails_overrides"

      # laod helpers
      helper_class = self.class.name.to_s.sub("Controller", "Helper")
      helper_path = "#{Jets.root}app/helpers/#{helper_class.underscore}.rb"
      ActiveSupport.on_load :action_view do
        include ApplicationHelper
        include helper_class.constantize if File.exist?(helper_path)
      end

      ActionController::Base.append_view_path("#{Jets.root}app/views")

      setup_webpacker
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
