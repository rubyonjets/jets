module Jets::Command
  module RakeDecorate
    # Decorate this method because this does not get called until runtime.
    # It's "lazy loaded" so we can avoid the Rails const being defined in general.
    def [](task_name, scopes=nil)
      super # => Rake::TaskManager#[]
    rescue RuntimeError => e
      # We require dummy/rails since this time because all the rake tasks have been loaded
      # and we need to load dummy/rails to get the database configurations. Normally,
      # we do not want to require dummy/rails because it defines the Rails.
      # However, a "command not found" error, more accurately,
      # a "rake task not found" error, has already been encountered.
      # Also:
      # require "dummy/rails" to prevent another error.
      #   from lib/active_record/railties/databases.rake
      #
      #   NoMethodError: undefined method `env' for Rails:Module (NoMethodError)
      #     database_configs = ActiveRecord::DatabaseConfigurations.new(databases).configs_for(env_name: Rails.env)
      #
      require "jets/overrides/dummy/rails"

      # Original error message from rake is something like this
      #
      #   Don't know how to build task 'foo:bar' (See the list of available tasks with `jets --tasks`)
      #
      # With an ugly backtrace.
      # We override the error message to be more user friendly.
      #
      # All of that in order for
      #   jets foo:bar
      # to show a pretty error message.
      $stderr.puts "ERROR: Could not find command: #{task_name.inspect}".color(:red)
      require "jets/commands/help/help_command"
      Jets::Command::HelpCommand.new.help
      exit 1
    end
  end
end
