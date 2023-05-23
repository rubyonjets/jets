# frozen_string_literal: true

module Jets
  module Command
    class InitializersCommand < Base # :nodoc:
      include EnvironmentArgument

      desc "initializers", "Print out all defined initializers in the order they are invoked by Jets."
      def perform
        extract_environment_option_from_argument
        require_application_and_environment!

        Jets.application.initializers.tsort_each do |initializer|
          say "#{initializer.context_class}.#{initializer.name}"
        end
      end
    end
  end
end
