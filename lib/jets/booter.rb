require "jets/core_ext/kernel" # Hack prevents Rails const from being defined

class Jets::Booter
  class << self
    @booted = false
    def boot!
      return if @booted

      confirm_jets_project!
      Jets::Bundle.require

      Jets.application.setup!
      check_ruby_version!

      # Turbines are loaded after setup_autoload_paths in Jets.application.setup!  Some Turbine options are defined
      # in the project so setup must happen before internal Turbines are loaded.
      load_internal_turbines

      run_turbines(:initializers)
      # Load configs after Turbine initializers so Turbines can defined some config options and they are available in
      # user's project environment configs.
      Jets.application.configs!
      app_initializers
      run_turbines(:after_initializers)
      Jets.application.finish!

      setup_db # establish db connections in Lambda Execution Context.
      # The eager load calls connects_to in models and establish those connections in Lambda Execution Context also.
      internal_finisher
      eager_load

      # TODO: Figure out how to build middleware during Jets.boot without breaking jets new and webpacker:install
      # build_middleware_stack

      @booted = true
    end

    # Runs right before eager_load
    def internal_finisher
      load_shared_extensions
    end

    # Shared extensions are added near the end because they require the Jets app load paths to first.
    # We eager load the extensions and then use the loaded modules to extend Jets::Stack directly.
    # Originally used an included hook but thats too early before app/shared/extensions is in the load_path.
    def load_shared_extensions
      base_path = "#{Jets.root}/app/shared/extensions"
      Dir.glob("#{base_path}/**/*.rb").each do |path|
        next unless File.file?(path)

        class_name = path.sub("#{base_path}/", '').sub(/\.rb/,'').camelize
        mod = class_name.constantize # autoload
        Jets::Stack.extend(mod)
      end
    end

    def eager_load
      preload_extensions
      Jets::Autoloaders.main.eager_load # Eager load project code. Rather have user find out early than later on AWS Lambda.
    end

    def preload_extensions
      base_path = "#{Jets.root}/app/extensions"
      Dir.glob("#{base_path}/**/*.rb").each do |path|
        next unless File.file?(path)

        class_name = path.sub("#{base_path}/", '').sub(/\.rb/,'').camelize
        klass = class_name.constantize # autoload
        Jets::Lambda::Functions.extend(klass)
      end
    end

    # Using ActiveRecord outside of Rails, so we need to set up the db connection ourself.
    #
    # Only connects to database for ActiveRecord and when config/database.yml exists.
    # Dynomite handles connecting to the clients lazily.
    def setup_db
      return unless File.exist?("#{Jets.root}/config/database.yml")

      db_configs = Jets.application.config.database
      # DatabaseTasks.database_configuration for db:create db:migrate tasks
      # Documented in DatabaseTasks that this is the right way to set it when
      # using ActiveRecord rake tasks outside of Rails.
      ActiveRecord::Tasks::DatabaseTasks.database_configuration = db_configs

      if db_configs.configs_for(env_name: Jets.env).blank?
        abort("ERROR: config/database.yml exists but no environment section configured for #{Jets.env}")
      end
      ActiveRecord::Base.configurations = db_configs
      connect_db
    end

    # Eager connect to database, so connections are established in the Lambda Execution Context and get reused.
    # Interestingly, the connections info is stored in the shared state but the connection doesnt show up on
    # `show processlist` until after a query. Have confirmed that the connection is reused and the connection count stays
    # the same.
    def connect_db
      if ActiveRecord::Base.legacy_connection_handling
        primary_hash_config = ActiveRecord::Base.configurations.configs_for(env_name: Jets.env).find { |hash_config|
          hash_config.name == "primary"
        }

        primary_config = primary_hash_config.configuration_hash # configuration_hash is a normal Ruby Hash

        ActiveRecord::Base.establish_connection(primary_config)
      else
        configs = ActiveRecord::Base.configurations.configs_for(env_name: Jets.env, include_replicas: true)

        databases = { }
        databases[:writing] = :primary if configs.any? { |config| config.name == "primary" }
        databases[:reading] = :primary_replica if configs.any? { |config| config.name == "primary_replica" }

        ActiveRecord::Base.connects_to database: databases
      end
    end

    def load_internal_turbines
      Jets::Autoloaders.once.on_setup do
        Jets::Mailer # only one right now
      end
    end

    # All Turbines
    def turbine_initializers
      Jets::Turbine.subclasses.each do |subclass|
        initializers = subclass.initializers || []
        initializers.each do |label, block|
          block.call(Jets.application)
        end
      end
    end

    # All Turbines
    def app_initializers
      Dir.glob("#{Jets.root}/config/initializers/**/*").sort.each do |path|
        load path
      end
    end

    # run_turbines(:initializers)
    # run_turbines(:after_initializers)
    def run_turbines(name)
      Jets::Turbine.subclasses.each do |subclass|
        hooks = subclass.send(name) || []
        hooks.each do |label, block|
          block.call(Jets.application)
        end
      end
    end

    # Builds and memoize stack so it only gets built on bootup
    def build_middleware_stack
      Jets.application.build_stack
    end

    # Cannot call this for the jets new
    def confirm_jets_project!
      unless File.exist?("#{Jets.root}/config/application.rb")
        puts "It does not look like you are running this command within a jets project.  Please confirm that you are in a jets project and try again.".color(:red)
        exit 1
      end
    end

    def message
      "Jets booting up in #{Jets.env.color(:green)} mode!"
    end

    def check_config_ru!
      config_ru = File.read("#{Jets.root}/config.ru")
      unless config_ru.include?("Jets.boot")
        puts 'The config.ru file is missing Jets.boot.  Please add Jets.boot after require "jets"'.color(:red)
        puts "This was changed as made in Jets v1.1.0."
        puts "To have Jets update the config.fu file for you, you can run:\n\n"
        puts "  jets upgrade"
        exit 1
      end
    end

    def check_ruby_version!
      return if ENV['JETS_RUBY_CHECK'] == '0'
      return if !Jets.config.ruby.check
      return if ruby_version_supported?

      puts <<~EOL.color(:red)
        You are using Ruby #{RUBY_VERSION}
        AWS Lambda does not support this version.
        Please use one of the supported Ruby versions: #{supported_ruby_versions.join(' ')}
      EOL

      puts <<~EOL
        If you would like to skip this check, you can set: JETS_RUBY_CHECK=0 or configure

        config/application.rb

            Jets.application.configure do
              config.ruby.check = false
            end

        Or if you want to allow additional Ruby versions, then configure:

        config/application.rb

            Jets.application.configure do
              config.ruby.supported_versions = ["2.5", "2.7", "3.2"]
            end

        Note: If AWS Lambda does not officially support the Ruby version,
        you'll need to also provide the Ruby Custom Runtime Layer.
        Related Docs: https://rubyonjets.com/docs/extras/custom-runtime/
      EOL
      exit 1
    end

    def ruby_version_supported?
      md = RUBY_VERSION.match(/(\d+)\.(\d+)\.\d+/)
      major, minor = md[1], md[2]
      detected_ruby = [major, minor].join('.')
      supported_ruby_versions.include?(detected_ruby)
    end

    def supported_ruby_versions
      Jets.config.ruby.supported_versions
    end
  end
end
