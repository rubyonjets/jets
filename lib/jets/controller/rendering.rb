class Jets::Controller
  module Rendering
    include Redirection

    def ensure_render
      return @rendered_data if @rendered

      # defaults to rendering templates
      RackRenderer.new(self, managed_options).render
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

      options.reverse_merge!(managed_options)
      adjust_content_type!(options)

      @rendered_data = RackRenderer.new(self, options).render

      @rendered = true
      @rendered_data
    end

    def adjust_content_type!(options)
      if options.key?(:json)
        options[:content_type] = "application/json"
      elsif options.key?(:xml)
        options[:content_type] = "application/xml"
      end
    end

    def managed_options
      layout = self.class.layout.nil? ? default_layout : self.class.layout
      options = { layout: layout }
      options[:headers] = response.headers unless response.headers.empty?
      options
    end

    def default_layout
      application_layout_exist = !Dir.glob("#{Jets.root}/app/views/layouts/application*").empty?
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

      Jets::Controller::Stage.add(actual_host, url)
    end

    def url_for(url)
      add_stage_name(url)
    end

    # Actual host can be headers["origin"] when cloudfront is in front.
    # Remember to set custom header "origin" header in cloudfront distribution.
    # Can also override with Jets.config.app.domain.
    # The actual_host value is used by redirect_to.
    def actual_host
      Jets.config.app.domain || headers["origin"] || headers["host"]
    end

  end
end
