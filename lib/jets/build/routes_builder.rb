class Jets::Build
  class RoutesBuilder
    attr_reader :routes
    def initialize
      @routes = []
    end

    def evaluate
      path = "#{Jets.root}/config/routes.rb"
      code = IO.read(path)
      instance_eval(code, path)
    end

    %w[get post put delete any].each do |method_name|
      define_method method_name do |path, options|
        create_route(options.merge(path: path, method: __method__))
      end
    end

    def create_route(options)
      @routes << Route.new(options)
    end

    # Class methods
    def self.draw
      builder = new
      builder.evaluate
      builder
    end

    @@routes = nil
    def self.routes
      @@routes ||= draw.routes
    end
  end
end
