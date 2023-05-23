# frozen_string_literal: true

module Jets
  module Command
    class ApplicationCommand < Base # :nodoc:
      hide_command!

      self.bin = "jets" if respond_to?(:bin=) # Rails 7.1

      def help
        perform # Punt help output to the generator.
      end

      # This is:
      #
      #   bundle exec jets application:help => jets new --help
      #   bundle exec jets application      => jets new --help
      #
      def perform(*args)
        # require lazily so that Rails constant is only defined within generators
        require "jets/generators/overrides/app/app_generator"
        override_exit_on_failure?
        argv = Rails::Generators::ARGVScrubber.new(args).prepare!
        Jets::Generators::AppGenerator.start argv
      end

    private
      # We override this way because Jets require generators lazily
      def override_exit_on_failure?
        Jets::Generators::AppGenerator.class_eval do
          # We want to exit on failure to be kind to other libraries
          # This is only when accessing via CLI
          def self.exit_on_failure?
            true
          end
        end
      end
    end
  end
end
