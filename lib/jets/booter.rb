class Jets::Booter
  class << self
    @booted = false
    def boot!(options={})
      return if @booted

      turbo_charge
      confirm_jets_project!
      require_bundle_gems unless bypass_bundler_setup?
      Jets::Dotenv.load!

      Jets.application.setup!
      # eager_load_jets is called to ensure that internal Turbines get loaded after auto_load paths configured in setup!
      eager_load_jets
      run_turbines(:initializers)
      # Load configs after Turbine initializers so Turbines can defined some config options
      # and they are available in user's project environment configs.
      Jets.application.configs!
      app_initializers
      run_turbines(:after_initializers)
      Jets.application.finish!

      # Eager load project code. Rather have user find out early than late.
      eager_load_app

      setup_db
      # build_middleware_stack # TODO: figure out how to build middleware during Jets.boot without breaking jets new and webpacker:install

      @booted = true
    end

    def bypass_bundler_setup?
      command = ARGV.first
      %w[build delete deploy url].include?(command)
    end

    def turbo_charge
      turbo = Jets::Turbo.new
      turbo.charge
    end

    # Builds and memoize stack so it only gets built on bootup
    def build_middleware_stack
      Jets.application.build_stack
    end

    def turbine_initializers
      Jets::Turbine.subclasses.each do |subclass|
        initializers = subclass.initializers || []
        initializers.each do |label, block|
          block.call(Jets.application)
        end
      end
    end

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
      if current_config.empty?
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

    # Eager load jet's lib and classes
    def eager_load_jets
      lib_jets = File.expand_path(".", File.dirname(__FILE__))

      # Sort by path length because systems return Dir.glob in different order
      # Sometimes it returns longer paths first which messed up eager loading.
      paths = Dir.glob("#{lib_jets}/**/*.rb")
      paths = paths.sort_by { |p| p.size }
      paths.select do |path|
        next if !File.file?(path)
        next if skip_eager_load_paths?(path)

        path = path.sub("#{lib_jets}/","jets/")
        class_name = path
                      .sub(/\.rb$/,'') # remove .rb
                      .sub(/^\.\//,'') # remove ./
                      .sub(/app\/\w+\//,'') # remove app/controllers or app/jobs etc
                      .camelize
        # special class mappings
        class_name = class_mappings(class_name)
        class_name.constantize # use constantize instead of require so dont have to worry about order.
      end
    end

    # Skip these paths because eager loading doesnt work for them.
    # Scope to /jets as much as possible in case it collides with a user path
    def skip_eager_load_paths?(path)
      path =~ %r{/jets/builders/rackup_wrappers} ||
      path =~ %r{/jets/builders/reconfigure_rails} ||
      path =~ %r{/jets/cli} ||
      path =~ %r{/jets/commands/templates/webpacker} ||
      path =~ %r{/jets/controller/middleware/webpacker_setup} ||
      path =~ %r{/jets/core_ext} ||
      path =~ %r{/jets/internal/app} ||
      path =~ %r{/jets/overrides} ||
      path =~ %r{/jets/spec} ||
      path =~ %r{/jets/stack} ||
      path =~ %r{/jets/turbo/project/} ||
      path =~ %r{/jets/version} ||
      path =~ %r{/templates/}
    end

    def class_mappings(class_name)
      map = {
        "Jets::Io" => "Jets::IO",
      }
      map[class_name] || class_name
    end

    # Eager load user's application
    def eager_load_app
      Dir.glob("#{Jets.root}/app/**/*.rb").select do |path|
        next if !File.file?(path) or path =~ %r{/javascript/} or path =~ %r{/views/}
        next if path.include?('app/functions') || path.include?('app/shared/functions') || path.include?('app/internal/functions')

        class_name = path
                      .sub(/\.rb$/,'') # remove .rb
                      .sub(%{^\./},'') # remove ./
                      .sub("#{Jets.root}/",'')
                      .sub(%r{app/shared/\w+/},'') # remove shared/resources or shared/extensions
                      .sub(%r{app/\w+/},'') # remove app/controllers or app/jobs etc
        class_name = class_name.classify
        class_name.constantize # use constantize instead of require so dont have to worry about order.
      end
    end
  end
end
