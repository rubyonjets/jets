require 'dsl_evaluator'

# The Jets::Router::RouteSet mimics the Rails interface.
# Jets works in a similar way to Rails.
# For example the url_helpers:
#
#   Jets.application.routes.url_helpers
#     => Jets.application.routes.named_routes.path_helpers_module
#       => Jets::Router::Helpers::NamedRoutes::Generated::MainAppHelpers
#
# Jets makes less use of anonymous modules. It uses generated named modules
# to help debugging. Whereas Rails:
#
#   Rails.application.routes.url_helpers => <Module>
#   Rails.application.routes.named_routes.path_helpers_module => <Module>
#   Rails.application.routes.named_routes.url_helpers_module  => <Module>
#
# Rails generates an anonymous module for url_helpers that wraps
# and includes the path_helpers_module and url_helpers_module.
#
# Jets tries to exhibit enough of the same as Rails interface to make it
# compatible with with ActionController and ActionView components.
#
module Jets::Router
  class RouteSet
    extend Memoist
    include Compat::RouteSet
    include Dsl

    # With Jets, this class is not a really a Collection. It's a wrapper
    # around Helpers::NamedRoutes::Generated which does the real work.
    # Naming it NamedRouteCollection to be consistent with Rails and possibly
    # in the future to make them more similar.
    class NamedRouteCollection
      attr_reader :url_helpers_module
      def initialize(route_set)
        @url_helpers_module = Helpers::NamedRoutes::Generated.create_helper_module(route_set)
      end

      # interface method
      # Rails AbstractController::UrlFor calls this method
      # Reason why this wrapper is needed.
      def helper_names
        url_helpers_module.path_helpers.map(&:to_s) +
        url_helpers_module.url_helpers.map(&:to_s)
      end

      delegate :remove_methods!, :add_methods!, to: :url_helpers_module
    end

    attr_reader :routes, :engine
    attr_accessor :draw_paths, :default_scope, :default_url_options,
      :disable_clear_and_finalize
    def initialize(engine=Jets.application)
      @engine = engine
      @engine_class = engine.class
      @default_url_options = {} # {host: "localhost"}
      @routes = []
      @draw_paths = [] # not part of clear! addtional paths: config/routes/admin.rb
      @prepend = []    # not part of clear! Otherwise breaks engines like sprockets-jets
      @append = []     # not part of clear!
      @finalized = false
      @disable_clear_and_finalize = false
      @default_scope = {}
    end

    # draw is called from config/routes.rb
    # load! is what we just internally to trigger it
    def draw(&block)
      clear! unless @disable_clear_and_finalize
      scope(default_scope) do
        instance_eval(&block)
      end
      finalize! unless @disable_clear_and_finalize
      check_collision!
    end

    # Be selective about what to clear. Keep other initialized instance variables
    # like @prepend, @append, @default_scope
    # Otherwise can break engines like sprockets-jets that use prepend.
    def clear!
      @finalized = false
      @routes = []
      @scope = Scope.new
      named_routes.remove_methods!
      @prepend.each { |blk| instance_eval(&blk) }
    end

    # Interface method for plugins.
    # Plugins like kingsman use to hook into Jets after routes are loaded.
    def finalize!
      return if @finalized
      @append.each { |blk| instance_eval(&blk) }
      load_external_paths
      named_routes.add_methods!
      @finalized = true
    end

    # additonal paths: config/routes/admin.rb
    def load_external_paths
      @draw_paths.each do |draw_path|
        Dir.glob("#{draw_path}/*.rb").each do |route_path|
          instance_eval(File.read(route_path), route_path.to_s)
        end
      end
    end

    def append(&block)
      @append << block
    end

    def prepend(&block)
      @prepend << block
    end

    # Rails interface method
    def eager_load!
      # noop for Jets
    end

    def url_helpers(supports_path = true)
      @url_helpers ||= named_routes.url_helpers_module
    end

    def mounted_helpers
      # Calling url_helpers to create the mounted_helpers proxy methods
      # IE: main_app and blorgh
      url_helpers
      @mounted_helpers ||= Helpers::NamedRoutes::Generated::MountedHelpers
    end

    def define_mounted_helper(name)
      Helpers::NamedRoutes::Generated.define_mounted_helper(name, self)
    end

    # Note: Jets assigns this to a instance varialbe in the initialize method
    # But Jets cannot do this because we currently eager load internally and
    # that routes draw would not be called in proper order.
    def named_routes
      NamedRouteCollection.new(self)
    end
    memoize :named_routes

    # Validate routes that deployable
    def check_collision!
      return if Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
      paths = self.routes.map(&:path)
      collision = Jets::Cfn::Resource::ApiGateway::RestApi::Routes::Collision.new
      collide = collision.collision?(paths)
      raise collision.exception if collide
    end

    def one_apigw_method_for_all_routes_warning(options)
      return unless options[:authorizer]
      return unless Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
      return if options[:path].starts_with?('*') # *catchall
      return if options[:path] == '' # root

      puts <<~EOL.color(:yellow)
        WARNING: Authorizer should not be set at individual routes when using

            config.cfn.build.routes == "one_apigw_method_for_all_routes"

        You should only set authorizer for the root route and *catchall route.
        The root route uses the root authorizer.
        And all other routes uses the *catchall authorizer.
        Docs: http://rubyonjets.com/docs/routing/authorizers/one-method/
      EOL
      DslEvaluator.print_code(routes_call_line) if routes_call_line
    end

    def routes_call_line
      caller.find { |l| l.include?('config/routes.rb') }
    end

    def api_mode?
      Jets.config.mode == 'api' || Jets.config.api_only
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
  end
end
