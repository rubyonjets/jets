class Jets::Router
  class Finder
    extend Memoist

    def initialize(path, method)
      @path = path
      @method = method.to_s.upcase
    end

    def run
      reset_routes!
      # Precedence:
      # 1. Routes with no captures get highest precedence: posts/new
      # 2. Then we consider the routes with captures: post/:id
      #
      # Within these 2 groups we consider the routes with the longest path first
      # since posts/:id and posts/:id/edit can both match.
      routes = router.ordered_routes
      route = routes.find do |r|
        matcher.match?(r)
      end
      route
    end

  private

    attr_reader :path, :method

    # "hot reload" for development
    def reset_routes!
      return unless Jets.env.development?

      Jets::Router.clear!
      Jets.application.load_routes(refresh: true)
    end

    def matcher
      Jets::Router::Matcher.new(path, method)
    end
    memoize :matcher

    def router
      Jets.application.routes
    end
    memoize :router
  end
end
