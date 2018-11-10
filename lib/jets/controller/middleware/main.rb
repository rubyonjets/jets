# All roads lead here
#
# 1. AWS Lambda: PostsController - Rack::Adapter - Jets.application.call
# 2. Local server:  config.ru - run Jet.application - Jets.application.call
#
# Then eventually:
#
#   Jets.application.call - Middleware stack - Jets::Controller::Middleware::Main
#
module Jets::Controller::Middleware
  class Main
    def initialize(env)
      @env = env
      @controller = env['jets.controller']
      @event = env['lambda.event']
      @context = env['lambda.context']
      @meth = env['lambda.meth']
    end

    def call
      dup.call!
    end

    def call!
      setup
      @controller.dispatch! # Returns triplet
    end

    # Common setup logical at this point of middleware processing right before
    # calling any controller actions.
    def setup
      # We already recreated a mimicke rack env earlier as part of the very first
      # middleware layer. However, by the time the rack env reaches the main middleware
      # it could had been updated by other middlewares. We update the env here again.
      @controller.request.set_env!(@env)
      # This allows sesison helpers to work. Sessions are managed by
      # the Rack::Session::Cookie middleware by default.
      @controller.session = @env['rack.session'] || {}
    end

    def self.call(env)
      instance = new(env)
      instance.call
    end
  end
end
