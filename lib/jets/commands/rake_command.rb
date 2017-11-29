class Jets::Commands::RakeCommand
  class << self
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

    # Useful for CLI.lookup.
    def namespaced_commands
      formatted_rake_tasks(true).map(&:first)
    end

    def formatted_rake_tasks(all=false)
      rake_tasks(all).map do |t|
        comment = "# #{t.comment}" if t.comment
        [ t.name_with_args, comment ]
      end
    end

    def rake_tasks(all=false)
      require_rake

      Rake::TaskManager.record_task_metadata = true
      rake.instance_variable_set(:@name, "jets")
      Jets::Commands::RakeTasks.load!
      tasks = rake.tasks
      tasks = tasks.select(&:comment) unless all
      tasks
    end

    def help_message(namespaced_command)
      task = rake_tasks(true).find { |t| t.name == namespaced_command }
      message = "Help provided by rake task:\n\n"
      message << "jets #{task.name_with_args.dup}\n"
      message << "    #{task.full_comment}"
      message
    end

  private
    def rake
      Rake.application
    end

    def require_rake
      require "rake" # Defer booting Rake until we know it's needed.
    end
  end
end
