require 'rack/request'

module Jets::Controller
  class Request
    include Rack::Request::Helpers
    include Compat::Request
    include Compat::Params

    include ActionDispatch::Flash::RequestMethods
    include ActionDispatch::Http::Cache::Request
    include ActionDispatch::Http::MimeNegotiation
    include ActionDispatch::Http::FilterParameters # parameter_filter and filtered_parameters
    include ActionDispatch::Http::URL
    include ActionDispatch::RequestCookieMethods
    include ActionDispatch::ContentSecurityPolicy::Request
    include ActionDispatch::PermissionsPolicy::Request
    include Rack::Request::Env

    # since jets delegates parameter_filter from controller to request
    public :parameter_filter

    attr_reader :event, :env
    attr_accessor :routes
    def initialize(rack_env: nil, event: nil)
      @rack_env = rack_env
      @event = event
      @env = normalize_env
      super(@env) # Rack::Env module => super()
    end

    def normalize_env
      if @rack_env # already rack env
        @rack_env # rack_env is from Controller.action => lambda { |env| .. }
      else
        Jets::Controller::RackAdapter::Env.new(@event, {}).convert # convert to Rack env
      end
    end

    # When request hits the middleware Controller::RackAdapter::Middleware::Main endpoint
    # We updated env since it could had been mutated down the middleware stack
    # from Mimic to Main.
    def set_env!(env)
      @env = env
    end
  end
end
