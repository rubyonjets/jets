require "shotgun"

module Jets::Middleware
  class DefaultStack
    attr_reader :config, :app
    def initialize(app, config)
      @app = app
      @config = config
    end

    def build_stack
      Stack.new do |middleware|
        middleware.use Shotgun::Static
        middleware.use Rack::Runtime
        middleware.use Jets::Controller::Middleware::Cors if cors_enabled?
        middleware.use Rack::MethodOverride unless ENV['JETS_RACK_METHOD_OVERRIDE'] == '0' # must come before Middleware::Local for multipart post forms to work
        middleware.use Jets::Controller::Middleware::Reloader if Jets.config.hot_reload
        middleware.use Jets::Controller::Middleware::Local # mimics AWS Lambda for local server only
        middleware.use session_store, session_options
        middleware.use Rack::Head
        middleware.use Rack::ConditionalGet
        middleware.use Rack::ETag
        use_webpacker(middleware)
      end
    end

  private
    def cors_enabled?
      Jets.config.cors
    end

    # Written as method to easily not include webpacker for case when either
    # webpacker not installed at all or disabled upon `jets deploy`.
    def use_webpacker(middleware)
      return unless Jets.webpacker? # checks for local development if webpacker installed
      # Different check for middleware because we need webpacker helpers for url helpers.
      # But we dont want to actually serve via webpacker middleware when running on AWS.
      # By this time the url helpers are serving assets out of s3.
      return if File.exist?("#{Jets.root}/config/disable-webpacker-middleware.txt") # created as part of `jets deploy`
      require "jets/controller/middleware/webpacker_setup"
      middleware.use Webpacker::DevServerProxy
    end

    def session_store
      Jets.config.session[:store] # do not use dot notation. session.store is a method on ActiveSupport::OrderedOptions.new
    end

    def session_options
      defaults = { secret: ENV['SECRET_KEY_BASE'] }
      defaults.merge(Jets.config.session.options)
    end
  end
end
