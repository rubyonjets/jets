require "thor"
require "byebug"

class Jets::CLI
  def self.start(given_args=ARGV)
    new(given_args).start
  end

  def initialize(given_args=ARGV, **config)
    @given_args = given_args.dup
    @thor_args = given_args.dup
    @config = config
  end

  def start
    if namespace
      klass = "Jets::Commands::#{namespace.classify}".constantize
      klass.send(:dispatch, nil, thor_args, nil, @config)
    else
      main_help
    end
  end

  def thor_args
    args = @thor_args.dup

    if args.first == "help"
      args[1] = meth
    else
      args[0] = meth
    end

    args.compact
  end

  def full_command
    @given_args[0] == "help" ?
      @given_args[1] :
      @given_args[0]
  end

  def namespace
    return nil unless full_command

    if full_command.include?(':')
      words = full_command.split(':')
      words.pop
      words.join(':')
    end
  end

  def meth
    return nil unless full_command

    if full_command.include?(':')
      full_command.split(':').pop
    else
      full_command
    end
  end

  def main_help
    list = []
    Jets::Commands::Base.eager_load!
    Jets::Commands::Base.subclasses.each do |klass|
      commands = klass.printable_commands(true, false)
      namespace = namespace_from_class(klass)
      commands.map! do |array|
        if namespace
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

    shell.say "Commands:"
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
