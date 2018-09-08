class Jets::Controller
  autoload :Renderers, "jets/controller/renderers"

  module Rendering
    include Redirection

    def ensure_render
      return @rendered_data if @rendered

      # defaults to rendering templates
      Renderers::TemplateRenderer.new(self, default_options).render
    end

    # Many different ways to render:
    #
    #  render "articles/index", layout: "application"
    #  render :new
    #  render template: "articles/index", layout: "application"
    #  render json: {my: "data"}
    #  render text: "plain text"
    def render(options={}, rest={})
      raise "DoubleRenderError" if @rendered

      if options.is_a?(Symbol) or options.is_a?(String)
        options = normalize_options(options, rest)
      end

      options.reverse_merge!(default_options)
      adjust_content_type!(options)
      @rendered_data = Renderers::TemplateRenderer.new(self, options).render

      @rendered = true
      @rendered_data
    end

    def adjust_content_type!(options)
      if options.key?(:json)
        options[:content_type] = "application/json"
      end
    end

    def default_options
      layout = self.class.layout.nil? ? default_layout : self.class.layout
      { layout: layout }
    end

    def default_layout
      application_layout_exist = !Dir.glob("#{Jets.root}app/views/layouts/application*").empty?
      "application" if application_layout_exist
    end

    # Can normalize the options when it is a String or a Symbol
    # Also set defaults here like the layout.
    # Ensure options is a Hash, not a String or Symbol.
    def normalize_options(options, rest)
      template = options.to_s
      rest.merge(template: template)
    end

    # Add API Gateway Stage Name
    def add_stage_name(url)
      return url unless actual_host

      if actual_host.include?("amazonaws.com") && url.starts_with?('/')
        stage_name = Jets::Resource::ApiGateway::Deployment.stage_name
        url = "/#{stage_name}#{url}"
      end
      url
    end

    def url_for(url)
      add_stage_name(url)
    end

    def actual_host
      headers["host"]
    end

  end
end
