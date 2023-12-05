# frozen_string_literal: true

module Jets
  module Command
    class HelpCommand < Base # :nodoc:
      hide_command!

      def help(*)
        say self.class.desc

        Jets::Command.print_commands
      end
    end
  end
end
