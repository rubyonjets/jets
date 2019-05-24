class Jets::Booter
  class << self
    @booted = false
    def boot!(options={})
      return if @booted

      turbo.charge
      confirm_jets_project!
      require_bundle_gems
      Jets::Dotenv.load!

      Jets.application.setup!

      # Turbines are loaded after setup_auto_load_paths in Jets.application.setup!  Some Turbine options are defined
      # in the project so setup must happen before internal Turbines are loaded.
      load_internal_turbines

      run_turbines(:initializers)
      # Load configs after Turbine initializers so Turbines can defined some config options and they are available in
      # user's project environment configs.
      Jets.application.configs!
      app_initializers
      run_turbines(:after_initializers)
      Jets.application.finish!

      # Eager load project code. Rather have user find out early than later on AWS Lambda.
      Jets::Autoloaders.main.eager_load

      setup_db
      # TODO: Figure out how to build middleware during Jets.boot without breaking jets new and webpacker:install
      # build_middleware_stack

      @booted = true
    end

    def load_internal_turbines
      Dir.glob("#{__dir__}/internal/turbines/**/*.rb").each do |path|
        Jets::Autoloaders.once.preload(path)
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
      Dir.glob("#{Jets.root}/config/initializers/**/*").each do |path|
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

    def turbo
      @turbo ||= Jets::Turbo.new
    end

    def bypass_bundler_setup?
      turbo.rails?
    end

    # require_bundle_gems called when environment boots up via Jets.boot.  It
    # also useful for when to loading Rake tasks in
    # Jets::Commands::RakeTasks.load!
    #
    # For example, some gems like webpacker that load rake tasks are specified
    # with a git based source:
    #
    #   gem "webpacker", git: "https://github.com/tongueroo/webpacker.git"
    #
    # This results in the user having to specific bundle exec in front of
    # jets for those rake tasks to show up in jets help.
    #
    # Instead, when the user is within the project folder, jets automatically
    # requires bundler for the user. So the rake tasks show up when calling
    # jets help.
    #
    # When the user calls jets help from outside the project folder, bundler
    # is not used and the load errors get rescued gracefully.  This is done in
    # Jets::Commands::RakeTasks.load!  In the case when there are in another
    # project with another Gemfile, the load errors will still be rescued.
    def require_bundle_gems
      return if bypass_bundler_setup?

      # NOTE: Dont think ENV['BUNDLE_GEMFILE'] is quite working right.  We still need
      # to be in the project directory.  Leaving logic in here for when it gets fix.
      if ENV['BUNDLE_GEMFILE'] || File.exist?("Gemfile")
        require "bundler/setup"
        Bundler.require(*bundler_groups)
      end
    end

    # Only connects connect to database for ActiveRecord and when
    # config/database.yml exists.
    # Dynomite handles connecting to the clients lazily.
    def setup_db
      return unless File.exist?("#{Jets.root}/config/database.yml")

      db_configs = Jets.application.config.database
      # DatabaseTasks.database_configuration for db:create db:migrate tasks
      # Documented in DatabaseTasks that this is the right way to set it when
      # using ActiveRecord rake tasks outside of Rails.
      ActiveRecord::Tasks::DatabaseTasks.database_configuration = db_configs

      current_config = db_configs[Jets.env]
      if current_config.blank?
        abort("ERROR: config/database.yml exists but no environment section configured for #{Jets.env}")
      end
      # Using ActiveRecord rake tasks outside of Rails, so we need to set up the
      # db connection ourselves
      ActiveRecord::Base.establish_connection(current_config)
    end

    def bundler_groups
      [:default, Jets.env.to_sym]
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
  end
end
