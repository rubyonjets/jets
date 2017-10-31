class Jets::Build
  class RoutesBuilder
    attr_reader :path, :routes
    def initialize(path=nil)
      @path = path || "#{Jets.root}/config/routes.rb"
      @routes = []
    end

    def evaluate
      code = IO.read(path)
      instance_eval(code, path)
    end

    # Methods supported by API Gateway
    %w[any delete get head options patch post put].each do |method_name|
      define_method method_name do |path, options|
        create_route(options.merge(path: path, method: __method__))
      end
    end

    # resources macro expands to all the routes
    def resources(name)
      get "#{name}", to: "#{name}#index"
      get "#{name}/:id", to: "#{name}#show"
      post "#{name}", to: "#{name}#create"
      get "#{name}/:id/edit", to: "#{name}#edit"
      put "#{name}", to: "#{name}#update"
      delete "#{name}", to: "#{name}#delete"
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
