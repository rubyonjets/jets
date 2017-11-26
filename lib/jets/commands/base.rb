require "thor"

class Jets::Commands::Base < Thor
  class << self
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

    # useful for help menu
    def eager_load!
      path = File.expand_path("../../", __FILE__)
      Dir.glob("#{path}/commands/**/*.rb").select do |path|
        next if !File.file?(path) or path =~ /templates/

        # puts "path #{path.inspect}"
        class_name = path
                      .sub('.rb','')
                      .sub(%r{.*/jets/commands}, 'jets/commands')
                      .classify
        # puts "  class_name #{class_name.inspect}"
        class_name.constantize # not using require so we dont have to worry about the ordering of the require
      end
    end

    # Fully qualifed task names. Examples:
    #   build
    #   process:controller
    #   dynamodb:migrate:down
    def namespaced_commands
      eager_load!
      subclasses.map do |klass|
        klass.all_tasks.keys.map do |task_name|
          klass = klass.to_s.sub('Jets::Commands::','')
          namespace = klass =~ /^Main/ ? nil : klass.underscore.gsub('/',':')
          [namespace, task_name].compact.join(':')
        end
      end.flatten.sort
    end

    # Use Jets banner instead of Thor to account for the namespace commands
    def banner(command, namespace = nil, subcommand = false)
      namespace = namespace_from_class(self)
      command_name = command.usage # set with desc when defining tht Thor class
      namespaced_command = [namespace, command_name].compact.join(':')

      "jets #{namespaced_command}"
    end

    def namespace_from_class(klass)
      namespace = klass.to_s.sub('Jets::Commands::', '').underscore.gsub('/',':')
      # puts "namespace #{namespace.inspect}"
      namespace unless namespace == "main"
    end

    def help_list(all=false)
      # hack to show hidden comands when requested
      Thor::HiddenCommand.class_eval do
        def hidden?; false; end
      end if all

      list = []
      Jets::Commands::Base.eager_load!
      Jets::Commands::Base.subclasses.each do |klass|
        commands = klass.printable_commands(true, false)
        commands.reject! { |array| array[0].include?(':help') }
        list += commands
      end

      list.sort_by! { |array| array[0] }
    end

    # thor_args is an array of commands. Examples:
    #   ["help"]
    #   ["dynamodb:migrate"]
    #
    # Same signature as RakeCommand.perform.  Not using full_command.
    def perform(full_command, thor_args)
      config = {} # doesnt seem like config is used
      dispatch(nil, thor_args, nil, config)
    end
  end
end
