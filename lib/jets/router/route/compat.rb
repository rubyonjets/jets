class Jets::Router::Route
  # Work in progress. Considering making Jets Route more compatiable with Rails Route.
  # Then will be able to leverage Rails RouteWrapper for presenting the routes for /jets/info/routes.
  # Ran into Route#path method that is a bit of work to make compatiable.
  # Leaving this here for the future.
  module Compat
    extend Memoist

    # Interface based on Rails ActionDispatch::Routing::Endpoint
    class App # :nodoc:
      def initialize(route)
        @route = route
      end

      def dispatcher?;   false; end
      def redirect?;     false; end
      def matches?(req);  true; end
      def app;            self; end
      def rack_app;        app; end

      def engine?
        @route.engine?
      end
    end

    def app
      App.new(self)
    end
    memoize :app

    # Rails interface method for ActionDispatch::Routing::RouteWrapper
    def name
      as || ''
    end

    # Rails interface method for ActionDispatch::Routing::RouteWrapper
    def verb
      http_method
    end

    def internal
      !!@options[:internal]
    end
  end
end