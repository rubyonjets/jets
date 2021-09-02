class Jets::Controller::Middleware::Local
  class RouteMatcher
    def initialize(env)
      @env = env
    end

    def find_route
      Jets::Router::Finder.new(path, method).run
    end

  private
    attr_reader :env

    def method
      env["REQUEST_METHOD"] || "GET"
    end

    def path
      env["PATH_INFO"].sub(/^\//,'')
    end
  end
end
