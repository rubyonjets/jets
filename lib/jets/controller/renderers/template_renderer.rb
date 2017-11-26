module Jets::Controller::Renderers
  class TemplateRenderer < BaseRenderer
    def controller_instance_variables
      @controller.instance_variables.inject({}) do |vars, v|
        k = v.to_s.sub(/^@/,'') # @var => var
        vars[k] = @controller.instance_variable_get(v)
        vars
      end
    end

    def render
      setup_action_controller # setup only when necessary

      # Rails rendering does heavy lifting
      renderer = ActionController::Base.renderer.new(renderer_options)
      body = renderer.render(render_options)
      @options[:body] = body # important to set as it was originally nil

      render_aws_proxy(@options)
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
      origin = headers["origin"]
      if origin
        uri = URI.parse(origin)
        https = uri.scheme == "https"
      end
      options = {
        http_host: headers["Host"],
        https: https,
        # script_name: "",
        # input: ""
      }
      @options[:method] = event["httpMethod"].downcase if event["httpMethod"]
      options
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
