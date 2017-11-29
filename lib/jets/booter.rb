class Jets::Booter
  class << self
    def boot!
      stdout_to_stderr

      confirm_jets_project!
      puts(boot_message) unless Jets.env.test?

      require_bundle_gems

      Jets::Dotenv.load!

      Jets.application.setup! # app configs: autoload_paths, routes, etc
      connect_to_db
    end

    # Override for Lambda processing.
    # $stdout = $stderr might seem weird but we want puts to write to stderr which
    # is set in the node shim to write to stderr.  This directs the output to
    # Lambda logs.
    # Printing to stdout managles up the payload returned from Lambda function.
    # This is not desired when returning payload to API Gateway eventually.
    def stdout_to_stderr
      $stdout.sync = true
      $stderr.sync = true
      $stdout = $stderr
    end

    # useful for cli usage
    def reset_stdout
      $stdout = STDOUT
    end

    # Use for rake tasks that defined in Gemfile source that are git based. Example:
    #   gem "webpacker", git: "git@github.com:tongueroo/webpacker.git"
    def require_bundle_gems
      # When boot! is called there will always be a Gemfile
      # because we call confirm_jets_project!  But let say the user calls
      # jets command from a folder that is not a jets project.  An example is
      # `jets help` from the user's home directory.
      # In that case we will not require the usage of bundler.
      # This could load to load errors but this use case is mainly isolated to
      # jets help.  So within jets help we can rescue load errors.  This is done in
      # Jets::RakeTasks.load!

      # NOTE: Dont think ENV['BUNDLE_GEMFILE'] is quite working right.  We still need
      # to be in the project directory.  Leaving logic in here for when it gets fix.
      if ENV['BUNDLE_GEMFILE'] || File.exist?("Gemfile")
        require "bundler/setup"
        Bundler.require(*bundler_groups)
      end
    end

    # Only connects connect to database for ActiveRecord and when
    # config/database.yml exists.
    # DynamodbModel handles connecting to the clients lazily.
    def connect_to_db
      database_yml = "#{Jets.root}config/database.yml"
      return unless File.exist?(database_yml)

      text = Jets::Erb.result(database_yml)
      config = YAML.load(text)
      ActiveRecord::Base.establish_connection(config[Jets.env])
    end

    def bundler_groups
      [:default, Jets.env.to_sym]
    end

    # Cannot call this for the jets new
    def confirm_jets_project!
      unless File.exist?("#{Jets.root}config/application.rb")
        puts "It does not look like you are running this command within a jets project.  Please confirm that you are in a jets project and try again.".colorize(:red)
        exit
      end
    end

    def boot_message
      "Jets booting up in #{Jets.env.colorize(:green)} mode!"
    end
  end
end
