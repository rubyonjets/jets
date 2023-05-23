# frozen_string_literal: true

module Jets::Command
  class GenerateCommand < Base # :nodoc:
    no_commands do
      # jets generate -h
      # Note: Other help flags like jets generate scaffold -h will be handled by
      # invoking the generator and letting it handle the help flag.
      def help
        require_application_and_environment!
        load_generators
        all_commands_help self.class.command_name
      end
    end

    desc "Generate", "Generate code"
    long_desc Help.text(:generate)
    def perform(*)
      # require lazily so that Rails constant is only defined within generators
      require "jets/generators"

      generator = args.shift
      return help unless generator

      require_application_and_environment!
      load_generators # engine.rb load_generators => Jets.application.load_generators

      ARGV.replace(args) # set up ARGV for third-party libraries

      Jets::Generators.invoke generator, args, behavior: behavior, destination_root: Jets::Command.root
    end

  private
    def behavior
      :invoke
    end

    def all_commands_help(command = "generate")
      puts "Usage: jets #{command} GENERATOR [args] [options]"
      puts
      puts "General options:"
      puts "  -h, [--help]     # Print generator's options and usage"
      puts "  -p, [--pretend]  # Run but do not make any changes"
      puts "  -f, [--force]    # Overwrite files that already exist"
      puts "  -s, [--skip]     # Skip files that already exist"
      puts "  -q, [--quiet]    # Suppress status output"
      puts
      puts "Please choose a generator below."
      puts

      Rails::Generators.print_generators
    end
  end
end

# Decorate the Group#help method to replace rails with jets.
#
# Note: Initially tried only decorating when a help flag like `-h` is detected
# but some commands will trigger help output without the flag.  For example:
#   jets generate job
# The command requires a name
#   jets generate job NAME
#
# The underlying Rails::Generators.invoke does this
#   if klass = find_by_namespace(names.pop, names.any? && names.join(":"))
#     args << "--help" if args.empty? && klass.arguments.any?(&:required?)
# and is able to detect that the name is missing and triggers the help output.
#
# Jets does not have this logic yet.  So we'll decorate the help method to
# at the Thor::Group#help level.
require "thor"
class Thor::Group
  module ReplaceHelpOutputWithJets
    def help(shell)
      out = capture_stdout_for_help do
        super # invoke to get the help output
      end
      puts out.gsub('rails','jets').gsub('Rails','Jets')
    end

    def capture_stdout_for_help
      stdout_old = $stdout
      io = StringIO.new
      $stdout = io
      yield
      $stdout = stdout_old
      io.string
    end
  end

  class << self
    # The help method is defined in the Thor::Group class.  We are decorating it
    prepend ReplaceHelpOutputWithJets
  end
end
