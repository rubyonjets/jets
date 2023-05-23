module Jets::Controller::Decorate
  module Redirecting
    include ApigwStage

    def _compute_redirect_to_location(request, options) # :nodoc:
      adjust = options.respond_to?(:to_str) || options.is_a?(String)
      options = add_apigw_stage(options) if adjust
      super
    end

    def redirect_back(fallback_location: '/')
      location = request.headers["Referer"] || fallback_location
      redirect_to location
    end
  end
end
