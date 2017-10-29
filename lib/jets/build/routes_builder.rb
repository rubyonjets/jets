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

    # Methods supported by API Gateway
    %w[any delete get head options patch post put].each do |method_name|
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

    # Returns all paths including subpaths.
    # Example:
    # Input: ["posts/:id/edit"]
    # Output: ["posts", "posts/:id", "posts/:id/edit"]
    @@all_paths = nil
    def self.all_paths
      return @@all_paths if @@all_paths

      results = []
      paths = routes.map(&:path)
      paths.each do |p|
        sub_paths = []
        parts = p.split('/')
        until parts.empty?
          parts.pop
          sub_path = parts.join('/')
          sub_paths << sub_path unless sub_path == ''
        end
        results += sub_paths
      end
      @@all_paths = (results + paths).sort.uniq
    end
  end
end
