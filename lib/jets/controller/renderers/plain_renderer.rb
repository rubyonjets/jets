module Jets::Controller::Renderers
  class PlainRenderer < BaseRenderer
    def render
      @options[:body] = @options[:plain]
      @options[:content_type] = "text/plain"
      render_aws_proxy(options)
    end
  end
end
