# frozen_string_literal: true

module Jets
  module Command
    class NewCommand < Base # :nodoc:
      no_commands do
        def help
          Jets::Command.invoke :application, [ "--help" ]
        end
      end

      def perform(*)
        say "Can't initialize a new Jets application within the directory of another, please change to a non-Jets directory first.\n"
        say "Type 'jets' for help."
        exit 1
      end
    end
  end
end
