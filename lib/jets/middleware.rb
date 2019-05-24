module Jets
  module Middleware
    extend Memoist

    def call(env)
      stack = middlewares.build(endpoint)
      stack.call(env)
    end

    # Final middleware in the stack
    def endpoint
      Jets::Controller::Middleware::Main
    end

    # Called in Jets::Booter to build middleware stack only once during bootup
    def build_stack
      middlewares
    end

    def middlewares
      config_middleware.merge_into(default_stack) # returns Jets::Middleware::Stack
    end
    memoize :middlewares

    def default_stack
      Jets::Middleware::DefaultStack.new(Jets.config, Jets.application).build_stack # returns Jets::Middleware::Stack
    end

    def config_middleware
      Jets.config.middleware # returns Jets::Middleware::Configurator
    end
  end
end