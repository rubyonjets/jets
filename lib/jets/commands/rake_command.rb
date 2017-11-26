class Jets::Commands::RakeCommand
  class << self
    def printing_commands
      formatted_rake_tasks.map(&:first)
    end

    # Same signature as Jets::Commands::Base.perform.
    def perform(namespaced_command, thor_args)
      if thor_args.first == "help"
        puts help_message(namespaced_command)
        return
      end

      require_rake

      ARGV.unshift(namespaced_command) # Prepend the task, so Rake knows how to run it.

      rake.standard_exception_handling do
        rake.init("jets")
        rake.load_rakefile
        rake.top_level
      end
    end

    def rake
      Rake.application
    end

    def rake_tasks
      require_rake

      return @rake_tasks if defined?(@rake_tasks)

      Rake::TaskManager.record_task_metadata = true
      rake.instance_variable_set(:@name, "jets")
      load_tasks
      @rake_tasks = rake.tasks.select(&:comment)
    end

    def help_message(namespaced_command)
      task = rake_tasks.find { |t| t.name == namespaced_command }
      message = "Help provided by rake task:\n\n"
      message << task.name_with_args.dup + "\n"
      message << "    #{task.full_comment}"
      message
    end

    def formatted_rake_tasks
      rake_tasks.map { |t| [ t.name_with_args, "# #{t.comment}" ] }
    end

  private
    def require_rake
      require "rake" # Defer booting Rake until we know it's needed.
    end

    def load_tasks
      Jets::RakeTasks.load!
    end
  end
end
