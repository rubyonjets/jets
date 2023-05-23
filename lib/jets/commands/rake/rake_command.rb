# frozen_string_literal: true

module Jets
  module Command
    class RakeCommand < Base # :nodoc:
      extend Jets::Command::Actions

      namespace "rake"

      class << self
        def printing_commands
          formatted_rake_tasks.map(&:first)
        end

        def perform(task, args, config)
          Jets.boot
          require_rake
          # Wonder if there's a better way to do this.
          # We do not use the rask_task block to require dummy/rails
          # because don't want Rails const to be defined for other rake tasks
          # like jets:assets:precompile. We want the Rails const to be defined
          # lazily at runtime only for db rake tasks.
          require "jets/overrides/dummy/rails" if task.include?("db:")

          Rake.with_application do |rake|
            rake.init("jets", [task, *args])
            rake.load_rakefile
            if Jets.respond_to?(:root)
              rake.options.suppress_backtrace_pattern = /\A(?!#{Regexp.quote(Jets.root.to_s)})/
            end
            rake.standard_exception_handling { rake.top_level }
          end
        end

        private
          def rake_tasks
            require_rake

            return @rake_tasks if defined?(@rake_tasks)

            require_application!

            Rake::TaskManager.record_task_metadata = true
            Rake.application.instance_variable_set(:@name, "jets")
            load_tasks
            @rake_tasks = Rake.application.tasks.select(&:comment)
          end

          def formatted_rake_tasks
            rake_tasks.map { |t| [ t.name_with_args, t.comment ] }
          end

          def require_rake
            require "rake" # Defer booting Rake until we know it's needed.
          end
      end
    end
  end
end
