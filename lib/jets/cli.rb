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
    command_class = lookup(full_command)
    if command_class
      command_class.perform(full_command, thor_args)
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
      klass = namespace.nil? ?
                Jets::Commands::Main :
                "Jets::Commands::#{namespace.classify}".constantize
      return klass
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
    shell = Thor::Shell::Basic.new
    shell.say "Commands:"
    shell.print_table(thor_list, :indent => 2, :truncate => true)
    shell.say "\nCommands via rake:"
    shell.print_table(rake_list, :indent => 2, :truncate => true)
    shell.say "\n"
    shell.say main_help_body
  end

  def thor_list
    Jets::Commands::Base.help_list(show_all_tasks)
  end

  def rake_list
    list = Jets::Commands::RakeCommand.formatted_rake_tasks(show_all_tasks)
    list.map do |array|
      array[0] = "jets #{array[0]}"
      array
    end
  end

  def show_all_tasks
    @given_args.include?("--all") || @given_args.include?("-A")
  end

  def main_help_body
    <<-EOL
For more help on each command add the -h flag to any of the commands.  Examples:

  jets call -h
  jets routes -h
  jets dynamodb:create -h
  jets db:create -h

EOL
  end

end
