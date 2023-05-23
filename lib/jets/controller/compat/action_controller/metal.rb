module Jets::Controller::Compat::ActionController
  module Metal
    extend ActiveSupport::Concern

    delegate :commit_flash,
             :filtered_parameters,
             :parameter_filter,
             :params,
             :reset_session,
             :session,
             :session=,
             :_routes,
             to: :request
    delegate :content_type,
             :content_type=,
             :get_header,
             :headers,
             :location,
             :location=,
             :media_type,
             :response_code,
             :set_header,
             :status,
             :status=,
             :to_a,
             to: :response
    attr_internal :request, :response

    alias :response_code :status # :nodoc:

    # End of the module include chain.
    # Go back from the ActionController::Base#initialize() interface
    # to the original Jets::Lambda::Functions#initialize(event, context, meth) interface
    def initialize
      super(@event, @context, @meth)
    end

    # One key difference between process! vs dispatch!
    #
    #    process! - takes the request through the middleware stack
    #    dispatch! - does not
    #
    # dispatch! is useful for megamode or mounted applications
    #
    def dispatch!
      # extend Jets.application.routes.url_helpers
      # extend Blorgh::Engine.routes.url_helpers

      # ActionView::Base.send :include, Jets.application.routes.url_helpers
      # ActionView::Base.send :include, Blorgh::Engine.routes.url_helpers
      # extend Jets.application.routes.mounted_helpers

      method_override!
      process_action
      commit_flash
      response.to_a
    end

    # Override @meth when POST with _method=delete
    # By the time processing reaches dispatch which calls method_override!
    # The Rack::MethodOverride middleware has overriden env['REQUEST_METHOD'] with DELETE
    # and set env['rack.methodoverride.original_method']
    def method_override!
      env = request.env
      if env['rack.methodoverride.original_method'] && env['REQUEST_METHOD'] == 'DELETE'
        @original_meth = @meth
        @meth = "destroy"
      end
    end

    # Not using rack.response.body directly because its value is wrapped in an Array, IE: [body]
    # and ActionController components check response_body assuming it can be nil or a String.
    # So we assign the String at the controller.response_body level and [body] at the
    # the Response#body= level.
    def response_body=(body)
      body = [body] unless body.nil? || body.respond_to?(:each)
      return unless body
      response.body = body
      super
    end

    # Unsure how Rails defines this but this is the Rails behavior according to the Kingsman/Devise port
    def response=(triplet)
      if triplet.is_a?(Array)
        status, headers, body = triplet
        self.status = status
        self.headers.merge!(headers)
        self.response_body = body
      else
        self.response_body = triplet # string
      end
    end

    # Tests if render or redirect has already happened.
    def performed?
      response_body || response.committed?
    end
  end
end
