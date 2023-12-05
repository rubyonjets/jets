require 'active_support/core_ext/module/remove_method'

module Jets::Router::Helpers::NamedRoutes
  module Generated
    def create_helper_module(route_set)
      module_name = helper_module_name(route_set)
      module_name.constantize rescue create_helper_module!(module_name, route_set)
    end

    def helper_module_name(route_set)
      engine_class = route_set.engine.class
      name = engine_class == Jets.app_class ? "main_app" : engine_class.engine_name
      name = name.gsub('::','')
      name = "#{name.camelize}Helpers" # MainAppHelpers or BlorghHelpers
      "Jets::Router::Helpers::NamedRoutes::Generated::#{name}"
    end

    def create_helper_module!(module_name, route_set)
      mod = Module.new do
        extend ActiveSupport::Concern # Needed for _url_for_modules to work since or UrlHelper ClassMethods not included
        mattr_accessor :path_helpers, default: Set.new
        mattr_accessor :url_helpers, default: Set.new

        include AddFullUrl

        # For compatibility with Rails url_helpers
        include ActionDispatch::Routing::UrlFor
        define_singleton_method(:_routes) { route_set } # needed for controller class context
        define_method(:_routes) { route_set } # needed for view context
        # Jets convenience method
        define_singleton_method(:route_set) { route_set }

        define_singleton_method(:_url_for_modules) { ActionView::RoutingUrlFor }
        define_method(:_url_for_modules) { ActionView::RoutingUrlFor }

        # Mimic Rails behavior
        # Precdence:
        #   1. config.action_mailer.default_url_options
        #   2. Jets.application.default_url_options
        def default_url_options
          self.class.default_url_options.empty? ? Jets.application.default_url_options : self.class.default_url_options
        end

        def add_methods!
          route_set.routes.each do |route|
            next unless route.as
            next if route.engine?

            name = route.as
            path_name = "#{name}_path"
            url_name  = "#{name}_url"
            engine_class = route_set.engine.class

            # Normally, self is <PostsController> or View context instance
            define_method(path_name) do |*args|
              NamedRouteMethod.new(route, args, self, engine_class).path
            end
            self.path_helpers.add(path_name)

            define_method(url_name) do |*args|
              path = send(path_name, *args)
              options = args.extract_options!
              add_full_url(options.merge(path: path))
            end
            self.url_helpers.add(url_name)
          end
        end

        def remove_methods!
          remove = Proc.new { |method| remove_method(method) }
          path_helpers.each(&:remove)
          url_helpers.each(&:remove)
          self.path_helpers.clear
          self.url_helpers.clear
        end

        # Wonder if extend self is may idea since it can allow context to be module itself
        # instead of the controller or view instance. However, it allows
        # Jets.application.routes.url_helpers.posts_path style calls in jets console
        extend self

        add_methods!
      end

      # Name it instead of using anonymous module to help debugging
      # IE: Jets::Router::Helpers::NamedRoutes::Generated::MainAppHelpers
      basename = module_name.split('::').last.to_sym
      Jets::Router::Helpers::NamedRoutes::Generated.const_set(basename, mod)

      define_mounted_helper(mod, route_set)

      mod
    end

    def define_mounted_helper(mod, route_set)
      name = mod.name.split('::').last.sub('Helpers','').underscore.to_sym
      return if MountedHelpers.method_defined?(name)

      helpers_module = route_set.url_helpers

      MountedHelpers.class_eval do
        define_method "_#{name}" do
          Jets::Router::Helpers::NamedRoutes::Proxy.new(self, helpers_module)
        end
      end

      MountedHelpers.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{name}
          @_#{name} ||= _#{name}
        end
      RUBY
    end

    module MountedHelpers
      extend ActiveSupport::Concern
    end

    # Contains all the mounted helpers across different
    # engines and the `main_app` helper for the application.
    # You can include this in your classes if you want to
    # access routes for other engines.
    def mounted_helpers
      MountedHelpers
    end

    extend self
  end

  class NamedRouteMethod
    include Jets::Controller::Decorate::ApigwStage

    attr_reader :options
    def initialize(route, args, context, engine_class)
      @route, @args, @context, @engine_class = route, args, context, engine_class
      @path = route.path # With placeholders still IE: /posts/:id
      @options = normalize_options(@path, args)
    end

    # Normalized with format in options
    # Helps to mimic Rails behavior.
    # Processes extra arguments to support format and query string.
    #
    #    post_path(post, "json", {foo: 'bar'}) => "/posts/1.json?foo=bar"
    #    post_path(post, {foo: 'bar'})         => "/posts/1?foo=bar"
    #
    def normalize_options(path, args)
      args = args.dup
      options = args.extract_options!
      # If there is still an argument in rest, it's the format. Rails behavior.
      rest = args[placeholders.size..-1]
      format = rest.last
      options[:format] = format if format
      options
    end

    def path
      query_string = @options.dup # make copy to modify
      format = query_string.delete(:format)
      query_string.delete(:action)
      query_string.delete(:controller)
      query_string.delete(:only_path)

      path = path_with_replaced_placeholders
      path = prepend_engine_mounted_at(path)
      path = "#{path}.#{format}" if format
      path = "#{path}?#{query_string.to_query}" unless query_string.empty?
      path = add_apigw_stage(path)
      path
    end

    # Needed for add_apigw_stage
    delegate :event, :request, to: :@context

    # IE: /posts/1
    def path_with_replaced_placeholders
      path = @path
      placeholders.each_with_index do |placeholder, index|
        path = path.gsub(placeholder, @args[index].to_param)
      end
      path
    end

    def placeholders
      @path.scan(/:\w+/)
    end

    def prepend_engine_mounted_at(path)
      mount = Jets::Router::EngineMount.find_by(engine: @engine_class)
      if mount
        path = path.delete_prefix('/')
        [mount.at, path].compact.join('/')
      else
        path
      end
    end
  end
end