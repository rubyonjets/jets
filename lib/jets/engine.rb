# frozen_string_literal: true

require "active_support/callbacks"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/try"
require "pathname"
require "thread"

module Jets
  class Engine < Turbine
    class << self
      attr_accessor :called_from, :isolated

      alias :isolated? :isolated
      alias :engine_name :turbine_name

      delegate :eager_load!, to: :instance

      def inherited(base)
        unless base.abstract_turbine?
          Jets::Turbine::Configuration.eager_load_namespaces << base

          base.called_from = begin
            call_stack = caller_locations.map { |l| l.absolute_path || l.path }

            File.dirname(call_stack.detect { |p| !p.match?(%r[turbines[\w.-]*/lib/jets|rack[\w.-]*/lib/rack]) })
          end
        end

        super
      end

      def find_root(from)
        find_root_with_flag "lib", from
      end

      def endpoint(endpoint = nil)
        @endpoint ||= nil
        @endpoint = endpoint if endpoint
        @endpoint
      end

      def isolate_namespace(mod)
        engine_name(generate_turbine_name(mod.name))

        routes.default_scope = { module: ActiveSupport::Inflector.underscore(mod.name) }
        self.isolated = true

        unless mod.respond_to?(:turbine_namespace)
          name, turbine = engine_name, self

          mod.singleton_class.instance_eval do
            define_method(:turbine_namespace) { turbine }

            unless mod.respond_to?(:table_name_prefix)
              define_method(:table_name_prefix) { "#{name}_" }
            end

            unless mod.respond_to?(:use_relative_model_naming?)
              class_eval "def use_relative_model_naming?; true; end", __FILE__, __LINE__
            end

            unless mod.respond_to?(:turbine_helpers_paths)
              define_method(:turbine_helpers_paths) { turbine.helpers_paths }
            end

            unless mod.respond_to?(:turbine_routes_url_helpers)
              define_method(:turbine_routes_url_helpers) { |include_path_helpers = true| turbine.routes.url_helpers(include_path_helpers) }
            end
          end
        end
      end

      # Finds engine with given path.
      def find(path)
        expanded_path = File.expand_path path
        Jets::Engine.subclasses.each do |klass|
          engine = klass.instance
          return engine if File.expand_path(engine.root) == expanded_path
        end
        nil
      end
    end

    include ActiveSupport::Callbacks
    define_callbacks :load_seed

    delegate :middleware, :root, :paths, to: :config
    delegate :engine_name, :isolated?, to: :class

    def initialize
      @_all_autoload_paths = nil
      @_all_load_paths     = nil
      @app                 = nil
      @config              = nil
      @env_config          = nil
      @helpers             = nil
      @routes              = nil
      @app_build_lock      = Mutex.new
      super
    end

    # Load console and invoke the registered hooks.
    # Check Jets::Turbine.console for more info.
    def load_console(app = self)
      require "jets/console/app"
      require "jets/console/helpers"
      run_console_blocks(app)
      self
    end

    # Load Jets runner and invoke the registered hooks.
    # Check Jets::Turbine.runner for more info.
    def load_runner(app = self)
      run_runner_blocks(app)
      self
    end

    # Load Rake and turbines tasks, and invoke the registered hooks.
    # Check Jets::Turbine.rake_tasks for more info.
    def load_tasks(app = self)
      require "rake"
      run_tasks_blocks(app) # loads tasks like db:migrate
      self
    end

    # Load Jets generators and invoke the registered hooks.
    # Check Jets::Turbine.generators for more info.
    def load_generators(app = self)
      require "jets/generators"
      run_generators_blocks(app)
      Jets::Generators.configure!(app.config.generators)
      self
    end

    # Invoke the server registered hooks.
    # Check Jets::Turbine.server for more info.
    def load_server(app = self)
      run_server_blocks(app)
      self
    end

    def eager_load!
      # Already done by Zeitwerk::Loader.eager_load_all. By now, we leave the
      # method as a no-op for backwards compatibility.
    end

    def turbines
      @turbines ||= Turbines.new
    end

    # Returns a module with all the helpers defined for the engine.
    def helpers
      @helpers ||= begin
        helpers = Module.new
        all = ActionController::Base.all_helpers_from_path(helpers_paths)
        ActionController::Base.modules_for_helpers(all).each do |mod|
          helpers.include(mod)
        end
        helpers
      end
    end

    # Returns all registered helpers paths.
    def helpers_paths
      paths["app/helpers"].existent
    end

    # Returns the underlying Rack application for this engine.
    def app
      @app || @app_build_lock.synchronize {
        @app ||= begin
          stack = default_middleware_stack
          config.middleware = build_middleware.merge_into(stack)
          config.middleware.build(endpoint)
        end
      }
    end

    # Returns the endpoint for this engine. If none is registered,
    # defaults to an ActionDispatch::Routing::RouteSet.
    def endpoint
      # self.class.endpoint || routes
      self.class.endpoint || Jets::Controller::Middleware::Main
    end

    # Define the Rack API for this engine.
    def call(env)
      env.merge!(env_config)
      app.call(env) # to Jets::Middleware#app
    end

    # Defines additional Rack env configuration that is added on each call.
    def env_config
      @env_config ||= {}
    end

    # Defines the routes for this engine. If a block is given to
    # routes, it is appended to the engine.
    def routes(&block)
      # @routes ||= ActionDispatch::Routing::RouteSet.new_with_config(config)
      @routes ||= Jets::Router::RouteSet.new(self)
      @routes.append(&block) if block_given?
      @routes
    end

    # Define the configuration object for the engine.
    def config
      @config ||= Engine::Configuration.new(self.class.find_root(self.class.called_from))
    end

    # Load data from db/seeds.rb file. It can be used in to load engines'
    # seeds, e.g.:
    #
    # Blog::Engine.load_seed
    def load_seed
      seed_file = paths["db/seeds.rb"].existent.first
      run_callbacks(:load_seed) { load(seed_file) } if seed_file
    end

    initializer :load_environment_config, before: :load_environment_hook, group: :all do
      paths["config/environments"].existent.each do |environment|
        require environment
      end
    end

    initializer :set_load_path, before: :bootstrap_hook do |app|
      _all_load_paths(app.config.add_autoload_paths_to_load_path).reverse_each do |path|
        $LOAD_PATH.unshift(path) if File.directory?(path)
      end
      $LOAD_PATH.uniq!
    end

    initializer :set_autoload_paths, before: :bootstrap_hook do
      ActiveSupport::Dependencies.autoload_paths.unshift(*_all_autoload_paths)
      ActiveSupport::Dependencies.autoload_once_paths.unshift(*_all_autoload_once_paths)

      config.autoload_paths.freeze
      config.autoload_once_paths.freeze
    end

    initializer :set_eager_load_paths, before: :bootstrap_hook do
      ActiveSupport::Dependencies._eager_load_paths.merge(config.eager_load_paths)
      config.eager_load_paths.freeze
    end

    initializer :add_routing_paths do |app|
      routing_paths = paths["config/routes.rb"].existent
      external_paths = self.paths["config/routes"].paths
      routes.draw_paths.concat(external_paths)

      if routes? || routing_paths.any?
        app.routes_reloader.paths.unshift(*routing_paths)
        app.routes_reloader.route_sets << routes
        app.routes_reloader.external_routes.unshift(*external_paths)
      end
    end

    # I18n load paths are a special case since the ones added
    # later have higher priority.
    initializer :add_locales do
      config.i18n.turbines_load_path << paths["config/locales"]
    end

    initializer :add_view_paths do
      views = paths["app/views"].existent
      unless views.empty?
        ActiveSupport.on_load(:jets_controller) { prepend_view_path(views) if respond_to?(:prepend_view_path) }
        ActiveSupport.on_load(:action_mailer) { prepend_view_path(views) }
      end
    end

    initializer :prepend_helpers_path do |app|
      if !isolated? || (app == self)
        app.config.helpers_paths.unshift(*paths["app/helpers"].existent)
      end
    end

    initializer :load_config_initializers do
      config.paths["config/initializers"].existent.sort.each do |initializer|
        load_config_initializer(initializer)
      end
    end

    initializer :wrap_executor_around_load_seed do |app|
      self.class.set_callback(:load_seed, :around) do |engine, seeds_block|
        app.executor.wrap(&seeds_block)
      end
    end

    initializer :engines_blank_point do
      # We need this initializer so all extra initializers added in engines are
      # consistently executed after all the initializers above across all engines.
    end

    rake_tasks do
      next if is_a?(Jets::Application)
      next unless has_migrations?

      namespace turbine_name do
        namespace :install do
          desc "Copy migrations from #{turbine_name} to application"
          task :migrations do
            ENV["FROM"] = turbine_name
            if Rake::Task.task_defined?("turbines:install:migrations")
              Rake::Task["turbines:install:migrations"].invoke
            else
              Rake::Task["app:turbines:install:migrations"].invoke
            end
          end
        end
      end
    end

    def routes? # :nodoc:
      @routes
    end

    protected
      def run_tasks_blocks(*) # :nodoc:
        super
        paths["lib/tasks"].existent.sort.each { |ext| load(ext) }
      end

    private
      def load_config_initializer(initializer) # :doc:
        ActiveSupport::Notifications.instrument("load_config_initializer.turbines", initializer: initializer) do
          load(initializer)
        end
      end

      def has_migrations?
        paths["db/migrate"].existent.any?
      end

      def self.find_root_with_flag(flag, root_path, default = nil) # :nodoc:
        while root_path && File.directory?(root_path) && !File.exist?("#{root_path}/#{flag}")
          parent = File.dirname(root_path)
          root_path = parent != root_path && parent
        end

        root = File.exist?("#{root_path}/#{flag}") ? root_path : default
        raise "Could not find root path for #{self}" unless root

        Pathname.new File.realpath root
      end

      def default_middleware_stack
        ActionDispatch::MiddlewareStack.new
      end

      def _all_autoload_once_paths
        config.autoload_once_paths.uniq
      end

      def _all_autoload_paths
        @_all_autoload_paths ||= begin
          autoload_paths  = config.autoload_paths
          autoload_paths += config.eager_load_paths
          autoload_paths -= config.autoload_once_paths
          autoload_paths.uniq
        end
      end

      def _all_load_paths(add_autoload_paths_to_load_path)
        @_all_load_paths ||= begin
          load_paths = config.paths.load_paths
          if add_autoload_paths_to_load_path
            load_paths += _all_autoload_paths
            load_paths += _all_autoload_once_paths
          end
          load_paths.uniq
        end
      end

      def build_middleware
        config.middleware
      end
  end
end
