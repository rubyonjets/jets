# All roads lead here
#
# 1. AWS Lambda: PostsController - Handler::Apigw - Jets.application.call
# 2. Local server:  config.ru - run Jet.application - Jets.application.call
#
# Then eventually:
#
#   Jets.application.call - Middleware stack - Jets::Controller::Middleware::Main
#
module Jets::Controller::Middleware
  class Main
    include Jets::ExceptionReporting

    def initialize(env)
      @env = env
      @controller = env['jets.controller'] # original controller instance from handler or mimic
      @context = env['jets.context']  # original AWS Lambda event or mimic context
      @event = env['jets.event']      # original AWS Lambda event or mimic event
      @meth = env['jets.meth']
    end

    def call
      dup.call!
    end

    # With exception reporting here instead of Controller::Base#process so any
    # exception in the middleware stack is caught.
    # Also using with_exception_reporting instead of
    # prepend Jets::ExceptionReporting::Process because the method is call!
    # not process. The interface is different.
    def call!
      with_exception_reporting do
        setup
        @controller.dispatch! # Returns triplet
      end
    end

    # Common setup logical at this point of middleware processing right before
    # calling any controller actions.
    def setup
      # We already recreated a mimic rack env earlier as part of the very first
      # middleware layer. However, by the time the rack env reaches the main middleware
      # it could had been updated by other middlewares. We update the env here again.
      @controller.request.set_env!(@env)
      # This allows sesison helpers to work. Sessions are managed by
      # the Rack::Session::Cookie middleware by default.
      @controller.session = @env['rack.session'] || {}
    end

    def jets_host
      protocol = @event.dig('headers', 'X-Forwarded-Proto') || @env['rack.url_scheme']
      default = "#{protocol}://#{@env['HTTP_HOST']}"
      Jets.config.helpers.host || default
    end

    def self.call(env)
      instance = new(env)
      instance.call
    end
  end
end
