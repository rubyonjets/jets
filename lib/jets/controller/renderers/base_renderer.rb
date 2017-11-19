# Interface:
#   subclasses must implement render
module Jets::Controller::Renderers
  class BaseRenderer
    def initialize(options={})
      @options = options
    end

    def render_aws_proxy(options)
      AwsProxyRenderer.new(options).render
    end
  end
end
