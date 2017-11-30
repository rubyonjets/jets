class Jets::Booter
  class << self
    def boot!
      stdout_to_stderr

      confirm_jets_project!

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

    # require_bundle_gems called when environment boots up via Jets.boot.  It
    # also useful for when to loading Rake tasks in
    # Jets::Commands::RakeTasks.load!
    #
    # For example, some gems like webpacker that load rake tasks are specified
    # with a git based source:
    #
    #   gem "webpacker", git: "git@github.com:tongueroo/webpacker.git"
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

    def message
      "Jets booting up in #{Jets.env.colorize(:green)} mode!"
    end
  end
end
