require 'text-table'

module Jets
  class Router
    include Dsl

    attr_reader :routes
    def initialize
      @routes = []
      @scope = Scope.new
    end

    def draw(&block)
      instance_eval(&block)
      check_collision!
    end

    # Validate routes that deployable
    def check_collision!
      paths = self.routes.map(&:path)
      collision = Jets::Resource::ApiGateway::RestApi::Routes::Collision.new
      collide = collision.collision?(paths)
      raise collision.exception if collide
    end

    def create_route(options)
      # TODO: Can use it to add additional things like authorization_type
      # Would be good to add authorization_type at the controller level also
      infer_to_option!(options)
      handle_on!(options)
      MethodCreator.new(options, @scope).define_url_helper!
      @routes << Route.new(options, @scope)
    end

    # Can possibly infer to option from the path. Example:
    #
    #     get 'posts/index'
    #     get 'posts', to: 'posts#index'
    #
    #     get 'posts/show'
    #     get 'posts', to: 'posts#show'
    #
    def infer_to_option!(options)
      return if options[:to]

      path = options[:path].to_s
      return unless path.include?('/')

      items = path.split('/')
      if items.size == 2
        options[:to] = items.join('#')
      end
    end

    def handle_on!(options)
      if options[:on] && !%w[resources resource].include?(@scope.from.to_s)
        raise Error.new("ERROR: The `on:` option can only be used within a resource or resources block")
      end
      options[:on] ||= @on_option if @on_option
    end

    def api_mode?
      if Jets.config.key?(:api_mode) || Jets.config.key?(:api_generator)
        puts <<~EOL.color(:yellow)
          DEPRECATED: Jets.config.api_generator
          Instead, please update your config/application.rb to use:
            Jets.config.mode = 'api'
          You can also run:
            jets upgrade
        EOL
      end
      api_mode = Jets.config.mode == 'api' || Jets.config.api_mode || Jets.config.api_generator
      api_mode
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
    # Routes with wildcards are considered after routes without wildcards
    #
    # Routes with fewer captures are ordered first since both
    # /posts/:post_id/comments/new and /posts/:post_id/comments/:id are equally
    # long
    #
    # Routes with the same amount of captures and wildcards are orderd so that
    # the longest path is considered first since posts/:id and posts/:id/edit
    # can both match.
    def ordered_routes
      length = Proc.new { |r| [r.path.count("*"), r.path.count(":"), r.path.length * -1] }
      routes.sort_by(&length)
    end

    class << self
      def has_controller?(name)
        routes.detect { |r| r.controller_name == name }
      end

      # Class methods
      def draw
        drawn_router
      end

      @@drawn_router = nil
      def drawn_router
        return @@drawn_router if @@drawn_router

        router = Jets.application.routes
        @@drawn_router = router
      end

      def clear!
        @@drawn_router = nil
        Jets::Router::Helpers::NamedRoutesHelper.clear!
      end

      def routes
        drawn_router.routes
      end

      # Returns all paths including subpaths.
      # Example:
      # Input: ["posts/:id/edit"]
      # Output: ["posts", "posts/:id", "posts/:id/edit"]
      def all_paths
        drawn_router.all_paths
      end

      def help(routes)
        return "Your routes table is empty." if routes.empty?

        table = Text::Table.new
        table.head = %w[As Verb Path Controller#action]
        routes.each do |route|
          table.rows << [route.as, route.method, route.path, route.to]
        end
        table
      end

      def all_routes_valid?
        invalid_routes.empty?
      end

      def invalid_routes
        routes.select { |r| !r.valid? }
      end

      def validate_routes!
        check_route_connected_functions
      end

      # Checks that all routes are validate and have corresponding lambda functions
      def check_route_connected_functions
        return true if all_routes_valid?

        puts "Please double check the routes below map to valid controllers:".color(:red)
        invalid_routes.each do |route|
          puts "  /#{route.path} => #{route.controller_name}##{route.action_name}"
        end
        false
      end
    end
  end
end
