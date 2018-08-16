require 'text-table'

module Jets
  class Router
    attr_reader :routes
    def initialize
      @routes = []
    end

    def draw(&block)
      instance_eval(&block)
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
      get "#{name}/new", to: "#{name}#new"
      get "#{name}/:id", to: "#{name}#show"
      post "#{name}", to: "#{name}#create"
      get "#{name}/:id/edit", to: "#{name}#edit"
      put "#{name}/:id", to: "#{name}#update"
      delete "#{name}/:id", to: "#{name}#delete"
    end

    def create_route(options)
      @routes << Route.new(options)
    end

    # root "posts#index"
    def root(to)
      @routes << Route.new(path: '', to: to, method: :get, root: true)
    end

    # Useful for creating API Gateway Resources
    def all_paths
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
      @all_paths = (results + paths).sort.uniq
    end

    # Useful for RouterMatcher
    #
    # Precedence:
    # 1. Routes with no captures get highest precedence: posts/new
    # 2. Then consider the routes with captures: post/:id
    # 3. Last consider the routes with wildcards: *catchall
    #
    # Within these 2 groups we consider the routes with the longest path first
    # since posts/:id and posts/:id/edit can both match.
    def ordered_routes
      length = Proc.new { |r| r.path.length * -1 }
      capture_routes = routes.select { |r| r.path.include?(':') }.sort_by(&length)
      wildcard_routes = routes.select { |r| r.path.include?('*') }.sort_by(&length)
      simple_routes = (routes - capture_routes - wildcard_routes).sort_by(&length)
      simple_routes + capture_routes + wildcard_routes
    end

    def self.has_controller?(name)
      routes.detect { |r| r.controller_name == name }
    end

    # Class methods
    def self.draw
      drawn_router
    end

    @@drawn_router = nil
    def self.drawn_router
      return @@drawn_router if @@drawn_router

      router = Jets.application.routes
      @@drawn_router = router
    end

    def self.routes
      drawn_router.routes
    end

    # Returns all paths including subpaths.
    # Example:
    # Input: ["posts/:id/edit"]
    # Output: ["posts", "posts/:id", "posts/:id/edit"]
    def self.all_paths
      drawn_router.all_paths
    end

    def self.routes_help
      return "Your routes table is empty." if routes.empty?

      table = Text::Table.new
      table.head = %w[Verb Path Controller#action]
      routes.each do |route|
        table.rows << [route.method, route.path, route.to]
      end
      table
    end

    def self.all_routes_valid
      invalid_routes.empty?
    end

    def self.invalid_routes
      routes.select { |r| !r.valid? }
    end
  end
end
