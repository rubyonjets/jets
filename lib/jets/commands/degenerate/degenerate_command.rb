# frozen_string_literal: true

require "jets/generators"
require "jets/commands/generate/generate_command"

module Jets
  module Command
    class DegenerateCommand < GenerateCommand # :nodoc:
      desc "Degenerate", "Opposite of generate. Removes the generated code."
      long_desc Help.text(:degenerate)
      def perform(*)
        super
      end

    private
      def behavior
        :revoke
      end
    end
  end
end
