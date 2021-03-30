require "thor"

# Override thor's long_desc identation behavior
# https://github.com/erikhuda/thor/issues/398
class Thor
  module Shell
    class Basic
      def print_wrapped(message, options = {})
        message = "\n#{message}" unless message.starts_with?("\n")
        stdout.puts message
      end
    end
  end
end

class Jets::Commands::Base < Thor
  class << self
    extend Memoist

    # thor_args is an array of commands. Examples:
    #   ["help"]
    #   ["dynamodb:migrate"]
    #
    # Same signature as RakeCommand.perform.  Not using full_command.
    def perform(full_command, thor_args)
      config = {} # doesnt seem like config is used
      dispatch(nil, thor_args, nil, config)
    end

    # Hacky way to handle error for 'jets new' when no project name is passed in to avoid
    # this error:
    #
    #   required arguments 'project_name' (Thor::RequiredArgumentMissingError)
    def dispatch(command, given_args, given_opts, config)
      if given_args.reject{|s| s =~ /^-/} == ['new'] # user forgot to pass a project name
        given_args = ['help', 'new']
      end
      super
    end

    # Track all command subclasses.
    def subclasses
      @subclasses ||= []
    end

    def inherited(base)
      super

      if base.name
        self.subclasses << base
      end
    end

    # Fully qualifed task names. Examples:
    #   build
    #   process:controller
    #   dynamodb:migrate:down
    def namespaced_commands
      eager_load!
      subclasses.map do |klass|
        # This all_tasks is part of Thor not the lambda/dsl.rb
        klass.all_tasks.keys.map do |task_name|
          klass = klass.to_s.sub('Jets::Commands::','')
          namespace = klass =~ /^Main/ ? nil : klass.underscore.gsub('/',':')
          [namespace, task_name].compact.join(':')
        end
      end.flatten.sort
    end

    # Use Jets banner instead of Thor to account for namespaces in commands.
    def banner(command, namespace = nil, subcommand = false)
      namespace = namespace_from_class(self)
      command_name = command.usage # set with desc when defining tht Thor class
      namespaced_command = [namespace, command_name].compact.join(':')

      "jets #{namespaced_command}"
    end

    def namespace_from_class(klass)
      namespace = klass.to_s.sub('Jets::Commands::', '').underscore.gsub('/',':')
      namespace unless namespace == "main"
    end

    def help_list(all=false)
      # hack to show hidden comands when requested
      Thor::HiddenCommand.class_eval do
        def hidden?; false; end
      end if all

      list = []
      eager_load!
      subclasses.each do |klass|
        commands = klass.printable_commands(true, false)
        commands.reject! { |array| array[0].include?(':help') }
        list += commands
      end

      list.sort_by! { |array| array[0] }
    end

    def klass_from_namespace(namespace)
      if namespace.nil?
        Jets::Commands::Main
      else
        class_name = namespace.gsub(':','/')
        class_name = "Jets::Commands::#{class_name.camelize}"
        class_name.constantize
      end
    end

    # If this fails to find a match then return the original full command
    def autocomplete(full_command)
      return nil if full_command.nil? # jets help

      eager_load!

      words = full_command.split(':')
      namespace = words[0..-2].join(':') if words.size > 1
      command = words.last

      # Thor's normalize_command_name autocompletes the command but then we need to add the namespace back
      begin
        thor_subclass = klass_from_namespace(namespace) # could NameError
        command = thor_subclass.normalize_command_name(command) # could Thor::AmbiguousCommandError
        [namespace, command].compact.join(':')
      rescue NameError
        full_command # return original full_command
      rescue Thor::AmbiguousCommandError => e
        puts "Unable to autodetect the command name. #{e.message}."
        full_command # return original full_command
      end
    end

    # For help menu to list all commands, we must eager load the command classes.
    #
    # There is special eager_load logic here because this is called super early as part of the CLI start.
    # We cannot assume we have full access to to the project yet.
    def eager_load!
      return if Jets::Turbo.afterburner?

      Jets::Autoloaders.cli.eager_load
    end
    memoize :eager_load!
  end
end
