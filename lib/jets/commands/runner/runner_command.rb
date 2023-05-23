# frozen_string_literal: true

module Jets
  module Command
    class RunnerCommand < Base # :nodoc:
      include EnvironmentArgument

      self.environment_desc = "The environment for the runner to operate under (test/development/production)"

      no_commands do
        def help
          super
          say self.class.desc
        end
      end

      def self.banner(*)
        "#{super} [<'Some.ruby(code)'> | <filename.rb> | -]"
      end

      desc "runner", "Run Ruby code in the context of Jets app non-interactively"
      long_desc Help.text(:runner)
      def perform(code_or_file = nil, *command_argv)
        extract_environment_option_from_argument

        unless code_or_file
          help
          exit 1
        end

        require_application_and_environment!
        Jets.application.load_runner

        args = command_argv

        ARGV.replace(command_argv)

        if code_or_file == "-"
          eval($stdin.read, TOPLEVEL_BINDING, "stdin")
        elsif File.exist?(code_or_file)
          expanded_file_path = File.expand_path code_or_file
          $0 = expanded_file_path
          Kernel.load expanded_file_path
        else
          begin
            # Jets changed TOPLEVEL_BINDING to binding to have access to args
            # To keep args working https://github.com/boltops-tools/jets/pull/669
            eval(code_or_file, binding, __FILE__, __LINE__)
          rescue SyntaxError, NameError => e
            error "Please specify a valid ruby command or the path of a script to run."
            error "Run '#{self.class.executable} -h' for help."
            error ""
            error e
            exit 1
          end
        end
      end
    end
  end
end
