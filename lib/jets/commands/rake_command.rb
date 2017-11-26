class Jets::Commands::RakeCommand
  class << self
    def printing_commands
      formatted_rake_tasks.map(&:first)
    end

    # Same signature as Jets::Commands::Base.perform.  Not using thor_args.
    def perform(task, *)
      require_rake

      ARGV.unshift(task) # Prepend the task, so Rake knows how to run it.

      rake_app.standard_exception_handling do
        rake_app.init("jets")
        rake_app.load_rakefile
        rake_app.top_level
      end
    end

    def rake_app
      Rake.application
    end

    def rake_tasks
      require_rake

      return @rake_tasks if defined?(@rake_tasks)

      Rake::TaskManager.record_task_metadata = true
      rake_app.instance_variable_set(:@name, "jets")
      load_tasks
      @rake_tasks = rake_app.tasks.select(&:comment)
    end

  private
    def formatted_rake_tasks
      rake_tasks.map { |t| [ t.name_with_args, t.comment ] }
    end

    def require_rake
      require "rake" # Defer booting Rake until we know it's needed.
    end

    def load_tasks
      Jets::RakeTasks.load!
    end
  end
end
