module Jets::Controller::Renderers
  class TemplateRenderer < BaseRenderer
    def controller_instance_variables
      instance_vars = @controller.instance_variables.inject({}) do |vars, v|
        k = v.to_s.sub(/^@/,'') # @var => var
        vars[k] = @controller.instance_variable_get(v)
        vars
      end
      instance_vars[:event] = event
      instance_vars
    end

    def render
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
        http_host: headers["host"],
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

    class << self
      def setup!
        require "action_controller"
        require "jets/rails_overrides"

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

Jets::Controller::Renderers::TemplateRenderer.setup!
