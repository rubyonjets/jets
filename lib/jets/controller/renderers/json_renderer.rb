module Jets::Controller::Renderers
  class JsonRenderer < BaseRenderer
    def render
      body = @options[:json]
      # to_attrs allows us to use:
      #   render json: {post: post}
      body = body.respond_to?(:to_attrs) ? body.to_attrs : body
      @options[:body] = body # important to set as it was originally @options[:json]

      render_aws_proxy(options)
    end
  end
end
