class Jets::Booter
  class << self
    @booted = false
    def boot!(options={})
      return if @booted

      redirect_output(options)
      confirm_jets_project!
      require_bundle_gems
      Jets::Dotenv.load!
      Jets.application # triggers application.setup! # autoload_paths, routes, etc
      setup_db

      @booted = true
    end

    # Override for Lambda processing.
    # $stdout = $stderr might seem weird but we want puts to write to stderr which
    # is set in the node shim to write to stderr.  This directs the output to
    # Lambda logs.
    # Printing to stdout managles up the payload returned from Lambda function.
    # This is not desired when returning payload to API Gateway eventually.
    #
    # Additionally, set both $stdout and $stdout to a StringIO object as a buffer.
    # At the end of the request, write this buffer to the filesystem.
    # In the node shim, read it back and write it to AWS Lambda logs.
    def redirect_output(options={})
      $stdout.sync = true
      $stderr.sync = true
      if options[:stringio]
        $stdout = $stderr = StringIO.new # for ruby_server and AWS Lambda to capture log
      else
        $stdout = $stderr # jets call and local jets operation
      end
    end

    # Used in ruby_server.rb
    def flush_output
      IO.write("/tmp/jets-output.log", $stdout.string)
      # Thanks: https://stackoverflow.com/questions/28445000/how-can-i-clear-a-stringio-instance
      $stdout.truncate(0)
      $stdout.rewind
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
      return unless File.exist?("#{Jets.root}config/database.yml")

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
