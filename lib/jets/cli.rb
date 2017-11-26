require "thor"
require "byebug"

class Jets::CLI
  def self.start(given_args=ARGV)
    new(given_args).start
  end

  def self.thor_tasks
    Jets::Commands::Base.namespaced_commands
  end

  def initialize(given_args=ARGV, **config)
    @given_args = given_args.dup
    @config = config
  end

  def start
    if meth and namespace.nil?
      Jets::Commands::Main.send(:dispatch, nil, thor_args, nil, @config)
      return
    end

    # command_class = find_by_namespace(namespace)
    command_class = lookup(full_command)
    if command_class.is_a?(Jets::Commands::RakeCommand)
      command_class.perform(thor_args, @config)
    elsif command_class.is_a?(Jets::Commands::Base)
      command_class.send(:dispatch, nil, thor_args, nil, @config)
    else
      main_help
    end
  end

  # 1. look up Thor tasks
  # 2. look up Rake tasks
  # 3. help menu with all commands when both Thor and Rake tasks are not found
  def lookup(full_command)
    thor_task_found = Jets::Commands::Base.namespaced_commands.include?(full_command)
    if thor_task_found
      return "Jets::Commands::#{namespace.classify}".constantize
    end

    rake_task_found = Jets::Commands::RakeCommand.namespaced_commands.include?(full_command)
    if rake_task_found
      return Jets::Commands::RakeCommand
    end
  end

  # ["-h", "-?", "--help", "-D", "help"]
  def help_flags
    Thor::HELP_MAPPINGS + ["help"]
  end

  def thor_args
    args = @given_args

    help_args = args & help_flags
    if help_args.empty?
      args[0] = meth # reassigns the command without the namespace
    else
      # allows using help flags at the end of the ocmmand to trigger the help menu
      args -= help_flags # remove "help" and help flags from args
      args[0] = meth # first command will always be the meth now since
        # we removed the help flags
      args.unshift("help")
    end
    args.compact
  end

  def full_command
    # Removes any args that starts with -, those are option args.
    # Also remove "help" flag.
    args = @given_args.reject {|o| o =~ /^-/ } - help_flags
    args[0] # first argument should always be the command
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
