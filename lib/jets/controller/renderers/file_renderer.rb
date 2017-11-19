require "rack/mime"

module Jets::Controller::Renderers
  class FileRenderer < BaseRenderer
    def render
      path = @options[:file].to_s
      path = "#{Jets.root}#{path}" unless path.starts_with?("/")
      content = IO.read(path)
      @options[:body] = content

      ext = File.extname(path)
      mime_type = Rack::Mime.mime_type(ext)
      @options[:content_type] = mime_type

      render_aws_proxy(@options)
    end
  end
end
