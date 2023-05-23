require "jets/core_ext/kernel" # Hack prevents Jets const from being defined

class Jets::Booter
  class << self
    @booted = false
    def boot!
      return if @booted
      confirm_jets_project!

      # Registration phase
      Jets::Bundle.require    # engine config and register initializers
      load_internal_engine    # internal engine initializers
      require_application!    # override with user customizations

      # Run phase
      Jets.application.initialize!
      @booted = true
    end

    def require_application!
      require ENGINE_PATH if defined?(ENGINE_PATH)

      if defined?(APP_PATH)
        check_old_jets_code!
        require APP_PATH
      else
        require "#{Jets.root}/config/application"
      end
    end

    def load_internal_engine
      require File.expand_path("../../engines/internal/lib/internal/engine.rb", __dir__)
    end

    # All Turbines
    def app_initializers
      Dir.glob("#{Jets.root}/config/initializers/**/*").sort.each do |path|
        load path
      end
    end

    # Cannot call this for the jets new
    # We check that within a jets project again as Jets.boot
    # Also checked in the jets/cli.rb more generally
    def confirm_jets_project!
      return if defined?(ENGINE_PATH)
      unless File.exist?("#{Jets.root}/config/application.rb")
        puts "It does not look like you are running this command within a jets project.  Please confirm that you are in a jets project and try again.".color(:red)
        exit 1
      end
    end

    def check_old_jets_code!
      application_rb = "#{Jets.root}/config/application.rb"
      return unless File.exist?(application_rb)
      return if File.read(application_rb).include?(' < Jets::Application')
      puts "ERROR: Based on config/application.rb, it looks like your app code was written with an older version of Jets.".color(:red)
      puts "Please install and run the jets-upgrade command to upgrade your project."
      puts "  jets-upgrade go".color(:green)
      exit 1
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
        puts "    jets-upgrade"
        exit 1
      end
    end
  end
end
