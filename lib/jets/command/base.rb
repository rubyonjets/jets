# frozen_string_literal: true

require "thor"
require "erb"

require "active_support/core_ext/string/filters"
require "active_support/core_ext/string/inflections"

require "jets/command/actions"

module Jets
  module Command
    class Base < Thor
      extend Memoist

      class Error < Thor::Error # :nodoc:
      end

      class CorrectableError < Error # :nodoc:
        attr_reader :key, :options

        def initialize(message, key, options)
          @key     = key
          @options = options
          super(message)
        end

        if defined?(DidYouMean::SpellChecker) && defined?(DidYouMean::Correctable)
          include DidYouMean::Correctable

          def corrections
            @corrections ||= DidYouMean::SpellChecker.new(dictionary: options).correct(key)
          end
        end
      end

      include Actions
      include AwsHelpers
      include ApiHelpers

      no_commands do
        cattr_accessor :full_namespace
      end

      class << self
        def long_desc(long_description, options = {})
          options[:wrap] = false
          super
        end

        def exit_on_failure? # :nodoc:
          false
        end

        # Returns true when the app is a Jets engine.
        def engine?
          defined?(ENGINE_ROOT)
        end

        # Tries to get the description from a USAGE file one folder above the command
        # root.
        def desc(usage = nil, description = nil, options = {})
          if usage
            super
          else
            @desc ||= ERB.new(File.read(usage_path), trim_mode: "-").result(binding) if usage_path
          end
        end

        # Convenience method to get the namespace from the class name. It's the
        # same as Thor default except that the Command at the end of the class
        # is removed.
        def namespace(name = nil)
          if name
            super
          else
            @namespace ||= super.chomp("_command").sub(/:command:/, ":")
          end
        end

        # Convenience method to hide this command from the available ones when
        # running jets command.
        def hide_command!
          Jets::Command.hidden_commands << self
        end

        def inherited(base) # :nodoc:
          super

          if base.name && !base.name.end_with?("Base")
            Jets::Command.subclasses << base
          end
        end

        def perform(full_namespace, command, args, config) # :nodoc:
          if Jets::Command::HELP_MAPPINGS.include?(args.first)
            command, args = "help", []
            self.full_namespace = full_namespace # store for help. clean:log => log
          end

          dispatch(command, args.dup, nil, config)
        rescue Thor::InvocationError => e
          puts e.message.color(:red) # message already has ERROR prefix
          self.full_namespace = full_namespace # store for help. clean:log => log
          dispatch("help", [], nil, config)
          exit 1
        end

        def printing_commands
          namespaced_commands
        end

        def executable
          "jets #{full_namespace || command_name}"
        end

        # Use Jets' default banner.
        def banner(*)
          command_name = full_namespace ? full_namespace.split(':').last : command_name
          command = commands[command_name]
          options_arg = '[options]' unless command && command.options.empty?
          output = "#{executable} #{arguments.map(&:usage).join(' ')} #{options_arg}".squish
          "  #{output}" # add 2 more spaces in front
        end

        # Sets the base_name taking into account the current class namespace.
        #
        #   Jets::Command::TestCommand.base_name # => 'jets'
        def base_name
          @base_name ||= if base = name.to_s.split("::").first
            base.underscore
          end
        end

        # Return command name without namespaces.
        #
        #   Jets::Command::TestCommand.command_name # => 'test'
        def command_name
          @command_name ||= if command = name.to_s.split("::").last
            command.chomp!("Command")
            command.underscore
          end
        end

        # Path to lookup a USAGE description in a file.
        def usage_path
          if default_command_root
            path = File.join(default_command_root, "USAGE")
            path if File.exist?(path)
          end
        end

        # Default file root to place extra files a command might need, placed
        # one folder above the command file.
        #
        # For a Jets::Command::TestCommand placed in <tt>jets/command/test_command.rb</tt>
        # would return <tt>jets/test</tt>.
        def default_command_root
          path = File.expand_path(relative_command_path, __dir__)
          path if File.exist?(path)
        end

        private
          # Allow the command method to be called perform.
          def create_command(meth)
            if meth == "perform"
              alias_method command_name, meth
            else
              # Prevent exception about command without usage.
              # Some commands define their documentation differently.
              @usage ||= ""
              @desc  ||= ""

              super
            end
          end

          def command_root_namespace
            (namespace.split(":") - %w(jets)).join(":")
          end

          def relative_command_path
            File.join("../commands", *command_root_namespace.split(":"))
          end

          def namespaced_commands
            commands.keys.map do |key|
              if command_root_namespace.match?(/(\A|:)#{key}\z/)
                command_root_namespace
              else
                "#{command_root_namespace}:#{key}"
              end
            end
          end
      end

      def help
        if full_namespace = self.class.full_namespace
          command_name = full_namespace.split(':').last # clean:log => log
          self.class.command_help(shell, command_name)
        elsif command_name = self.class.command_name
          self.class.command_help(shell, command_name)
        else
          super
        end
      end
    end
  end
end
