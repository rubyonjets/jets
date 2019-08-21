class Jets::Controller::Middleware::Local
  class RouteMatcher
    def initialize(env)
      @env = env
    end

    def find_route
      Jets::Router::Finder.new(method, path).run
    end

    private

      attr_reader :env

      def path
        env["REQUEST_METHOD"] || "GET"
      end

      def method
        env["PATH_INFO"].sub(/^\//,'')
      end
    end
end
