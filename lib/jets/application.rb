# frozen_string_literal: true

require "yaml"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/object/blank"
require "active_support/key_generator"
require "active_support/message_verifier"
require "active_support/encrypted_configuration"
require "active_support/hash_with_indifferent_access"
require "active_support/configuration_file"

module Jets
  class Application < Engine
    class << self
      def inherited(base)
        super
        Jets.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base)
      end

      def instance
        super.run_load_hooks!
      end

      def create(initial_variable_values = {}, &block)
        new(initial_variable_values, &block).run_load_hooks!
      end

      def find_root(from)
        find_root_with_flag "config.ru", from, Dir.pwd
      end

      # Makes the +new+ method public.
      #
      # Note that Jets::Application inherits from Jets::Engine, which
      # inherits from Jets::Turbine and the +new+ method on Jets::Turbine is
      # private
      public :new
    end

    attr_accessor :assets, :sandbox
    alias_method :sandbox?, :sandbox
    attr_reader :reloaders, :reloader, :executor, :autoloaders

    delegate :default_url_options, :default_url_options=, to: :routes

    INITIAL_VARIABLES = [:config, :turbines, :routes_reloader, :reloaders,
                         :routes, :helpers, :app_env_config, :secrets] # :nodoc:

    def initialize(initial_variable_values = {}, &block)
      super()
      @initialized       = false
      @reloaders         = []
      @routes_reloader   = nil
      @app_env_config    = nil
      @ordered_turbines  = nil
      @turbines          = nil
      @message_verifiers = {}
      @ran_load_hooks    = false

      @executor          = Class.new(ActiveSupport::Executor)
      @reloader          = Class.new(ActiveSupport::Reloader)
      @reloader.executor = @executor

      @autoloaders = Jets::Autoloaders.new

      # are these actually used?
      @initial_variable_values = initial_variable_values
      @block = block
    end

    # Returns true if the application is initialized.
    def initialized?
      @initialized
    end

    def run_load_hooks! # :nodoc:
      return self if @ran_load_hooks
      @ran_load_hooks = true

      @initial_variable_values.each do |variable_name, value|
        if INITIAL_VARIABLES.include?(variable_name)
          instance_variable_set("@#{variable_name}", value)
        end
      end

      instance_eval(&@block) if @block
      self
    end

    # Reload application routes regardless if they changed or not.
    def reload_routes!
      routes_reloader.reload!
    end

    # Returns the application's KeyGenerator
    def key_generator
      # number of iterations selected based on consultation with the google security
      # team. Details at https://github.com/jets/jets/pull/6952#issuecomment-7661220
      @caching_key_generator ||= ActiveSupport::CachingKeyGenerator.new(
        ActiveSupport::KeyGenerator.new(secret_key_base, iterations: 1000)
      )
    end

    # Returns a message verifier object.
    #
    # This verifier can be used to generate and verify signed messages in the application.
    #
    # It is recommended not to use the same verifier for different things, so you can get different
    # verifiers passing the +verifier_name+ argument.
    #
    # ==== Parameters
    #
    # * +verifier_name+ - the name of the message verifier.
    #
    # ==== Examples
    #
    #     message = Jets.application.message_verifier('sensitive_data').generate('my sensible data')
    #     Jets.application.message_verifier('sensitive_data').verify(message)
    #     # => 'my sensible data'
    #
    # See the ActiveSupport::MessageVerifier documentation for more information.
    def message_verifier(verifier_name)
      @message_verifiers[verifier_name] ||= begin
        secret = key_generator.generate_key(verifier_name.to_s)
        ActiveSupport::MessageVerifier.new(secret)
      end
    end

    # Convenience for loading config/foo.yml for the current Jets env.
    #
    # Examples:
    #
    #     # config/exception_notification.yml:
    #     production:
    #       url: http://127.0.0.1:8080
    #       namespace: my_app_production
    #
    #     development:
    #       url: http://localhost:3001
    #       namespace: my_app_development
    #
    #     # config/environments/production.rb
    #     Jets.application.configure do
    #       config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    #     end
    #
    #     # You can also store configurations in a shared section which will be
    #     # merged with the environment configuration
    #
    #     # config/example.yml
    #     shared:
    #       foo:
    #         bar:
    #           baz: 1
    #
    #     development:
    #       foo:
    #         bar:
    #           qux: 2
    #
    #     # development environment
    #     Jets.application.config_for(:example)[:foo][:bar]
    #     # => { baz: 1, qux: 2 }
    def config_for(name, env: Jets.env)
      yaml = name.is_a?(Pathname) ? name : Pathname.new("#{paths["config"].existent.first}/#{name}.yml")

      if yaml.exist?
        require "erb"
        all_configs    = ActiveSupport::ConfigurationFile.parse(yaml).deep_symbolize_keys
        config, shared = all_configs[env.to_sym], all_configs[:shared]

        if shared
          config = {} if config.nil? && shared.is_a?(Hash)
          if config.is_a?(Hash) && shared.is_a?(Hash)
            config = shared.deep_merge(config)
          elsif config.nil?
            config = shared
          end
        end

        if config.is_a?(Hash)
          config = ActiveSupport::OrderedOptions.new.update(config)
        end

        config
      else
        raise "Could not load configuration. No such file - #{yaml}"
      end
    end

    # Stores some of the Jets initial environment parameters which
    # will be used by middlewares and engines to configure themselves.
    def env_config
      @app_env_config ||= super.merge(
          "action_dispatch.parameter_filter" => config.filter_parameters,
          "action_dispatch.redirect_filter" => config.filter_redirect,
          "action_dispatch.secret_key_base" => secret_key_base,
          "action_dispatch.show_exceptions" => config.action_dispatch.show_exceptions,
          "action_dispatch.show_detailed_exceptions" => config.consider_all_requests_local,
          "action_dispatch.log_rescued_responses" => config.action_dispatch.log_rescued_responses,
          "action_dispatch.logger" => Jets.logger,
          "action_dispatch.backtrace_cleaner" => Jets.backtrace_cleaner,
          "action_dispatch.key_generator" => key_generator,
          "action_dispatch.http_auth_salt" => config.action_dispatch.http_auth_salt,
          "action_dispatch.signed_cookie_salt" => config.action_dispatch.signed_cookie_salt,
          "action_dispatch.encrypted_cookie_salt" => config.action_dispatch.encrypted_cookie_salt,
          "action_dispatch.encrypted_signed_cookie_salt" => config.action_dispatch.encrypted_signed_cookie_salt,
          "action_dispatch.authenticated_encrypted_cookie_salt" => config.action_dispatch.authenticated_encrypted_cookie_salt,
          "action_dispatch.use_authenticated_cookie_encryption" => config.action_dispatch.use_authenticated_cookie_encryption,
          "action_dispatch.encrypted_cookie_cipher" => config.action_dispatch.encrypted_cookie_cipher,
          "action_dispatch.signed_cookie_digest" => config.action_dispatch.signed_cookie_digest,
          "action_dispatch.cookies_serializer" => config.action_dispatch.cookies_serializer,
          "action_dispatch.cookies_digest" => config.action_dispatch.cookies_digest,
          "action_dispatch.cookies_rotations" => config.action_dispatch.cookies_rotations,
          "action_dispatch.cookies_same_site_protection" => coerce_same_site_protection(config.action_dispatch.cookies_same_site_protection),
          "action_dispatch.use_cookies_with_metadata" => config.action_dispatch.use_cookies_with_metadata,
          "action_dispatch.content_security_policy" => config.content_security_policy,
          "action_dispatch.content_security_policy_report_only" => config.content_security_policy_report_only,
          "action_dispatch.content_security_policy_nonce_generator" => config.content_security_policy_nonce_generator,
          "action_dispatch.content_security_policy_nonce_directives" => config.content_security_policy_nonce_directives,
          "action_dispatch.permissions_policy" => config.permissions_policy,
        )
    end

    # If you try to define a set of Rake tasks on the instance, these will get
    # passed up to the Rake tasks defined on the application's class.
    def rake_tasks(&block)
      self.class.rake_tasks(&block)
    end

    # Sends the initializers to the +initializer+ method defined in the
    # Jets::Initializable module. Each Jets::Application class has its own
    # set of initializers, as defined by the Initializable module.
    def initializer(name, opts = {}, &block)
      self.class.initializer(name, opts, &block)
    end

    # Sends any runner called in the instance of a new application up
    # to the +runner+ method defined in Jets::Turbine.
    def runner(&blk)
      self.class.runner(&blk)
    end

    # Sends any console called in the instance of a new application up
    # to the +console+ method defined in Jets::Turbine.
    def console(&blk)
      self.class.console(&blk)
    end

    # Sends any generators called in the instance of a new application up
    # to the +generators+ method defined in Jets::Turbine.
    def generators(&blk)
      self.class.generators(&blk)
    end

    # Sends any server called in the instance of a new application up
    # to the +server+ method defined in Jets::Turbine.
    def server(&blk)
      self.class.server(&blk)
    end

    # Sends the +isolate_namespace+ method up to the class method.
    def isolate_namespace(mod)
      self.class.isolate_namespace(mod)
    end

    ## Jets internal API

    # This method is called just after an application inherits from Jets::Application,
    # allowing the developer to load classes in lib and use them during application
    # configuration.
    #
    #   class MyApplication < Jets::Application
    #     require "my_backend" # in lib/my_backend
    #     config.i18n.backend = MyBackend
    #   end
    #
    # Notice this method takes into consideration the default root path. So if you
    # are changing config.root inside your application definition or having a custom
    # Jets application, you will need to add lib to $LOAD_PATH on your own in case
    # you need to load files in lib/ during the application configuration as well.
    def self.add_lib_to_load_path!(root) # :nodoc:
      path = File.join root, "lib"
      if File.exist?(path) && !$LOAD_PATH.include?(path)
        $LOAD_PATH.unshift(path)
      end
    end

    def require_environment! # :nodoc:
      environment = paths["config/environment"].existent.first
      require environment if environment
    end

    def routes_reloader # :nodoc:
      @routes_reloader ||= RoutesReloader.new
    end

    # Returns an array of file paths appended with a hash of
    # directories-extensions suitable for ActiveSupport::FileUpdateChecker
    # API.
    def watchable_args # :nodoc:
      files, dirs = config.watchable_files.dup, config.watchable_dirs.dup

      ActiveSupport::Dependencies.autoload_paths.each do |path|
        File.file?(path) ? files << path.to_s : dirs[path.to_s] = [:rb]
      end

      [files, dirs]
    end

    # Initialize the application passing the given group. By default, the
    # group is :default
    def initialize!(group = :default) # :nodoc:
      raise "Application has been already initialized." if @initialized
      run_initializers(group, self)
      @initialized = true
      self
    end

    def initializers # :nodoc:
      Bootstrap.initializers_for(self) +
      turbines_initializers(super) +
      Finisher.initializers_for(self)
    end

    def config # :nodoc:
      @config ||= Application::Configuration.new(self.class.find_root(self.class.called_from))
    end

    attr_writer :config

    def secrets
      @secrets ||= begin
        secrets = ActiveSupport::OrderedOptions.new
        files = config.paths["config/secrets"].existent
        files = files.reject { |path| path.end_with?(".enc") } unless config.read_encrypted_secrets
        secrets.merge! Jets::Secrets.parse(files, env: Jets.env)

        # Fallback to config.secret_key_base if secrets.secret_key_base isn't set
        secrets.secret_key_base ||= config.secret_key_base

        secrets
      end
    end

    attr_writer :secrets, :credentials

    # The secret_key_base is used as the input secret to the application's key generator, which in turn
    # is used to create all ActiveSupport::MessageVerifier and ActiveSupport::MessageEncryptor instances,
    # including the ones that sign and encrypt cookies.
    #
    # In development and test, this is randomly generated and stored in a
    # temporary file in <tt>tmp/development_secret.txt</tt>.
    #
    # In all other environments, we look for it first in <tt>ENV["SECRET_KEY_BASE"]</tt>,
    # then +credentials.secret_key_base+, and finally +secrets.secret_key_base+. For most applications,
    # the correct place to store it is in the encrypted credentials file.
    def secret_key_base
      if Jets.env.development? || Jets.env.test?
        secrets.secret_key_base ||= generate_development_secret
      else
        validate_secret_key_base(
          ENV["SECRET_KEY_BASE"] || credentials.secret_key_base || secrets.secret_key_base
        )
      end
    end

    # Returns an ActiveSupport::EncryptedConfiguration instance for the
    # credentials file specified by +config.credentials.content_path+.
    #
    # By default, +config.credentials.content_path+ will point to either
    # <tt>config/credentials/#{environment}.yml.enc</tt> for the current
    # environment (for example, +config/credentials/production.yml.enc+ for the
    # +production+ environment), or +config/credentials.yml.enc+ if that file
    # does not exist.
    #
    # The encryption key is taken from either <tt>ENV["JETS_MASTER_KEY"]</tt>,
    # or from the file specified by +config.credentials.key_path+. By default,
    # +config.credentials.key_path+ will point to either
    # <tt>config/credentials/#{environment}.key</tt> for the current
    # environment, or +config/master.key+ if that file does not exist.
    def credentials
      @credentials ||= encrypted(config.credentials.content_path, key_path: config.credentials.key_path)
    end

    # Returns an ActiveSupport::EncryptedConfiguration instance for an encrypted
    # file. By default, the encryption key is taken from either
    # <tt>ENV["JETS_MASTER_KEY"]</tt>, or from the +config/master.key+ file.
    #
    #   my_config = Jets.application.encrypted("config/my_config.enc")
    #
    #   my_config.read
    #   # => "foo:\n  bar: 123\n"
    #
    #   my_config.foo.bar
    #   # => 123
    #
    # Encrypted files can be edited with the <tt>bin/jets encrypted:edit</tt>
    # command. (See the output of <tt>bin/jets encrypted:edit --help</tt> for
    # more information.)
    def encrypted(path, key_path: "config/master.key", env_key: "JETS_MASTER_KEY")
      ActiveSupport::EncryptedConfiguration.new(
        config_path: Jets.root.join(path),
        key_path: Jets.root.join(key_path),
        env_key: env_key,
        raise_if_missing_key: config.require_master_key
      )
    end

    def to_app # :nodoc:
      self
    end

    def helpers_paths # :nodoc:
      config.helpers_paths
    end

    console do
      unless ::Kernel.private_method_defined?(:y)
        require "psych/y"
      end
    end

    # Return an array of turbines respecting the order they're loaded
    # and the order specified by the +turbines_order+ config.
    #
    # While running initializers we need engines in reverse order here when
    # copying migrations from turbines ; we need them in the order given by
    # +turbines_order+.
    def migration_turbines # :nodoc:
      ordered_turbines.flatten - [self]
    end

    # Eager loads the application code.
    def eager_load!
      Jets.autoloaders.each(&:eager_load)
    end

    # Added for Application::Configuration::Defaults
    def aws
      @aws ||= Jets::AwsInfo.new
    end

  protected
    alias :build_middleware_stack :app

    def run_tasks_blocks(app) # :nodoc:
      turbines.each { |r| r.run_tasks_blocks(app) }
      super
      load "jets/tasks.rb"
      task :environment do
        ActiveSupport.on_load(:before_initialize) { config.eager_load = config.rake_eager_load }

        require_environment!
      end
    end

    def run_generators_blocks(app) # :nodoc:
      turbines.each { |r| r.run_generators_blocks(app) }
      super
    end

    def run_runner_blocks(app) # :nodoc:
      turbines.each { |r| r.run_runner_blocks(app) }
      super
    end

    def run_console_blocks(app) # :nodoc:
      turbines.each { |r| r.run_console_blocks(app) }
      super
    end

    def run_server_blocks(app) # :nodoc:
      turbines.each { |r| r.run_server_blocks(app) }
      super
    end

    # Returns the ordered turbines for this application considering turbines_order.
    def ordered_turbines # :nodoc:
      @ordered_turbines ||= begin
        order = config.turbines_order.map do |turbine|
          if turbine == :main_app
            self
          elsif turbine.respond_to?(:instance)
            turbine.instance
          else
            turbine
          end
        end

        all = (turbines - order)
        all.push(self)   unless (all + order).include?(self)
        order.push(:all) unless order.include?(:all)

        index = order.index(:all)
        order[index] = all
        order
      end
    end

    def turbines_initializers(current) # :nodoc:
      initializers = []
      ordered_turbines.reverse.flatten.each do |t|
        if t == self
          initializers += current
        else
          initializers += t.initializers
        end
      end
      initializers
    end

    def default_middleware_stack # :nodoc:
      default_stack = DefaultMiddlewareStack.new(self, config, paths)
      default_stack.build_stack
    end

    def validate_secret_key_base(secret_key_base)
      if secret_key_base.is_a?(String) && secret_key_base.present?
        secret_key_base
      elsif secret_key_base
        raise ArgumentError, "`secret_key_base` for #{Jets.env} environment must be a type of String`"
      else
        raise ArgumentError, "Missing `secret_key_base` for '#{Jets.env}' environment, set this string with `bin/jets credentials:edit`"
      end
    end

    private
      def generate_development_secret
        if secrets.secret_key_base.nil?
          # key_file = Jets.root.join("tmp/development_secret.txt")
          key_file = Pathname.new("/tmp/jets/#{Jets.project_name}/development_secret.txt")

          if !File.exist?(key_file)
            random_key = SecureRandom.hex(64)
            FileUtils.mkdir_p(key_file.dirname)
            File.binwrite(key_file, random_key)
          end

          secrets.secret_key_base = File.binread(key_file)
        end

        secrets.secret_key_base
      end

      def build_middleware
        config.app_middleware + super
      end

      def coerce_same_site_protection(protection)
        protection.respond_to?(:call) ? protection : proc { protection }
      end
  end
end
