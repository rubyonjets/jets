require "thor"
require "byebug"

class Jets::Command
  class << self
    def start(given_args=ARGV, **config)
      full_command = full_command(given_args)
      namespace, meth = namespace_and_meth(full_command)
      thor_args = thor_args(given_args)

      if namespace
        klass = "Jets::Commands::#{namespace.classify}".constantize
        klass.send(:dispatch, nil, thor_args, nil, config)
      else
        main_help
      end
    end

    def thor_args(given_args)
      full_command = full_command(given_args)
      namespace, meth = namespace_and_meth(full_command)

      thor_args = given_args.dup
      if given_args.first == "help"
        thor_args[1] = meth
      else
        thor_args[0] = meth
      end

      thor_args.compact
    end

    def full_command(given_args)
      given_args[0] == "help" ?
        given_args[1] :
        given_args[0]
    end

    def namespace_and_meth(full_command)
      if full_command.nil?
        meth = nil
        namespace = nil
      elsif full_command.include?(':')
        words = full_command.split(':')
        meth = words.pop
        namespace = words.join(':')
      else
        meth = full_command
        namespace = nil
      end
      [namespace, meth]
    end

    def main_help
      # puts Jets::Commands::Foo.help(Thor::Shell::Basic.new)
      shell.say "Commands:"

      list = []
      # TODO: use inherited to store the list of classes
      klasses = [
        Jets::Commands::Foo,
        Jets::Commands::Dynamodb,
        Jets::Commands::Dynamodb::Migrate,
        Jets::Commands::Main,
      ]
      klasses.each do |klass|
        commands = klass.printable_commands(true, false)
        namespace = namespace_from_class(klass)
        # puts "namespace2 #{namespace}"
        commands.map! do |array|
          if namespace
            # puts "array[0] #{array[0]}"
            array[0].sub!("jets ", "jets #{namespace}:")
            array[0] += " [options]"
          end
          array
        end
        commands.reject! { |array| array[0].include?(':help') }
        list += commands
      end

      first_help = ["jets help", "# Describe available commands or one specific command"]
      list.sort_by! { |array| array[1] }
      list.unshift(first_help)
      shell.print_table(list, :indent => 2, :truncate => true)
    end

    def namespace_from_class(klass)
      namespace = klass.to_s.sub('Jets::Commands::', '').underscore.gsub('/',':')
      # puts "namespace #{namespace.inspect}"
      namespace unless namespace == "main"
    end

    def shell
      @shell ||= Thor::Shell::Basic.new
    end
  end
end
