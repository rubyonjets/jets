require 'rack/request'

class Jets::Controller
  class Request < ::Rack::Request
    def initialize(event, context)
      @event, @context = event, context
      super(env)
    end

    def env
      @env ||= Jets::Controller::Rack::Env.new(@event, @context).convert # convert to Rack env
    end

    # When request hits the middleware Controller::Rack::Middleware::Main endpoint
    # We set the it with the updated env since it could had been mutated down the
    # middleware stack.
    def set_env!(env)
      @env = env
    end

    # API Gateway is inconsistent about how it cases it keys.
    # Sometimes it is "x-requested-with" vs "X-Requested-With"
    # Normalize it with downcase.
    def headers
      headers = @event["headers"] || {}
      headers.transform_keys { |key| key.downcase }
    end
  end
end
