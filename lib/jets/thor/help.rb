module Jets::Thor
  module Help
    extend ActiveSupport::Concern

    def help(command = nil, subcommand = false)
      help_output = capture_stdout_for_help { super }
      paginate_output(help_output)
    end

    def capture_stdout_for_help
      stdout_old = $stdout
      io = StringIO.new
      $stdout = io
      yield
      $stdout = stdout_old
      io.string
    end

    # Method to paginate the output using less if necessary
    def paginate_output(output)
      unless system("type less > /dev/null 2>&1")
        puts output
        return
      end

      # Paginate the output if it's taller than the terminal
      terminal_height = TTY::Screen.height
      if output.lines.count > terminal_height
        IO.popen("less -R", "w") { |less| less.puts(output) }
      else
        puts output
      end
    end

    module ClassMethods
      # Override command_help to include the description at the top of the
      # long_description.
      def command_help(shell, command_name)
        meth = normalize_command_name(command_name)
        command = all_commands[meth]
        alter_command_description(command)
        super
      end

      def alter_command_description(command)
        return unless command

        # Add description to beginning of long_description
        long_desc = if command.long_description
          "#{command.description}\n\n#{command.long_description}"
        else
          command.description
        end

        # add reference url to end of the long_description
        unless website.empty?
          full_command = [command.ancestor_name, command.name].compact.join("-")
          url = "#{website}/reference/Jets::Pro-#{full_command}"
          long_desc += "\n\nHelp also available at: #{url}"
        end

        command.long_description = long_desc
      end
      private :alter_command_description

      # override main help menu
      def help(shell, subcommand = false)
        if subcommand
          help_subcommand(shell, subcommand)
        else
          help_main(shell, subcommand)
        end
      end

      def help_subcommand(shell, subcommand)
        list = command_list(subcommand)
        shell.say "Commands:\n\n"
        shell.print_table(list, indent: 2, truncate: true)
      end

      def help_main(shell, subcommand = false)
        list = command_list(subcommand)

        filter = proc do |command, desc|
          main_commands.detect { |name| command =~ Regexp.new("^jets #{name}") }
        end
        main = list.select(&filter)
        other = list.reject(&filter)

        shell.say "Usage: jets COMMAND [args]"
        shell.say "\nMain Commands:\n\n"
        shell.print_table(main, indent: 2, truncate: true)
        shell.say "\nOther Commands:\n\n"
        shell.print_table(other, indent: 2, truncate: true)
        shell.say <<~EOL

          For more help on each command, you can use the -h option. Example:

            jets deploy -h

          CLI Reference also available at: https://docs.rubyonjets.com/reference/
        EOL
      end

      def command_list(subcommand)
        list = printable_commands(true, subcommand)
        Thor::Util.thor_classes_in(self).each do |klass|
          list += klass.printable_commands(false)
        end
        list.reject! do |arr|
          c = arr[0] # IE: jets release:SUBCOMMAND
          c.include?("help") ||
            c.include?("COMMAND") ||
            c.include?("c_l_i")
        end
        sort_commands!(list)
        list
      end

      def main_commands
        %w[
          deploy
          logs
          url
        ]
      end
    end
  end
end
