require "jets/core_ext/kernel" # Hack prevents Rails const from being defined

class Jets::Booter
  class << self
    @booted = false
    def boot!
      return if @booted

      confirm_jets_project!
      Jets::Bundle.require

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

      setup_db

      # Eager load project code. Rather have user find out early than later on AWS Lambda.
      Jets::Autoloaders.main.eager_load

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
      ActiveRecord::Base.configurations = current_config
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
