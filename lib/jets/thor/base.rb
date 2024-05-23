require "thor"
require "tty-screen"

module Thor::StartOverride
  class << self
    def included(base)
      super
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def start(given_args = ARGV, config = {})
      # Trap ^C
      Signal.trap("INT") {
        puts "\nCtrl-C detected. Exiting..."
        sleep 0.1
        exit
      }

      # Namespace subcommands separate by colon instead of space
      if given_args && given_args[0]&.include?(":")
        commands = given_args.shift.split(":")
        given_args.unshift(commands)
        given_args.flatten!
      end

      super
    end
  end
end
Thor.include Thor::StartOverride

module Thor::CreateCommandOverride
  def create_command(meth) # :nodoc:
    @long_desc ||= long_desc_from_help_file(self, meth)
    super
  end

  # So we don't have to duplicate the long_desc Thor CLI classes
  def long_desc_from_help_file(klass, meth)
    folder = klass.name.demodulize.underscore unless klass == Jets::CLI
    path = ["../cli/help", folder, "#{meth}.md"].compact.join("/")
    path = File.expand_path(path, __dir__)
    if File.exist?(path)
      IO.read(path)
    end
  end
end

class Thor
  class << self
    prepend Thor::CreateCommandOverride
  end
end

module Thor::FormattedUsageOverride
  def formatted_usage(klass, namespace = true, subcommand = false)
    usage = super
    # Namespace subcommands separate by colon instead of space
    items = formatted_usage_by_colons(usage)
  end

  def formatted_usage_by_colons(input)
    words = input.split(/\s+/)

    formatted = words.map.with_index do |word, index|
      next_word = words[index + 1]
      if next_word.nil? || next_word == next_word.upcase
        "#{word} "
      else
        "#{word}:"
      end
    end

    formatted.join.gsub(": ", ":").strip
  end
end
Thor::Command.prepend Thor::FormattedUsageOverride

# Override thor's long_desc identation behavior
# https://github.com/erikhuda/thor/issues/398
class Thor
  module Shell
    class Basic
      def print_wrapped(message, options = {})
        message = "\n#{message}" unless message[0] == "\n"
        stdout.puts message
      end
    end
  end
end

module Jets::Thor
  class Base < Thor
    include SharedOptions
    include Help

    class << self
      def dispatch(m, args, options, config)
        # Allow calling for help via:
        #   jets command help
        #   jets command -h
        #   jets command --help
        #
        # as well thor's normal way:
        #
        #   jets help command
        if args.length > 1 && !(args & help_flags).empty?
          args -= help_flags
          args.insert(-2, "help")
        end

        if args.length == 1 && !(args & version_flags).empty?
          args = ["version"]
        end

        VersionCheck.new.check!
        ProjectCheck.new(args).check!
        auth = Jets::Thor::Auth.new(args)
        auth.check!
        super
      rescue Jets::Api::Error::Unauthorized => e
        auth.handle_unauthorized(e)
      rescue ProjectCheck::NotProjectError
        puts "Not a Jets project. Please run this command from a Jets project folder.".color(:red)
      end

      # Also used by Jets::Thor::Auth
      def help_flags
        Thor::HELP_MAPPINGS + ["help"]
      end

      # Also used by Jets::Thor::Auth
      #   jets version
      #   jets --version
      #   jets -v
      def version_flags
        ["--version", "-v"]
      end

      # meant to be overriden
      def website
        ""
      end

      # https://github.com/erikhuda/thor/issues/244
      # Deprecation warning: Thor exit with status 0 on errors. To keep this behavior, you must define `exit_on_failure?` in `Lono::Commands`
      # You can silence deprecations warning by setting the environment variable THOR_SILENCE_DEPRECATION.
      def exit_on_failure?
        true
      end
    end
  end
end
