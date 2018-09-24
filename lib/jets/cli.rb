require "thor"

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
      boot_jets
      command_class.perform(full_command, thor_args)
    elsif version_requested?
      puts Jets.version
    else
      main_help
    end
  end

  def version_requested?
    #   jets --version
    #   jets -v
    version_flags = ["--version", "-v"]
    @given_args.length == 1 && !(@given_args & version_flags).empty?
  end

  # The commands new and help do not call Jets.boot. Main reason is that
  # Jets.boot are ran inside a Jets project folder.
  #
  # * jets new - need to generate a project outside a project folder.
  # * jets help - don't need to be in a project folder general help.
  #   When you are inside a project folder though, more help commands
  #   are available and displayed.
  #
  def boot_jets
    command = thor_args.first
    if !%w[new help].include?(command)
      set_jets_env_for_deploy_command!
      Jets.boot
    end
  end

  # Adjust JETS_ENV before boot_jets is called for the jets deploy
  # command.  Must do this early in the process before Jets.boot because
  # Jets.boot calls Jets.env as part of the bootup process in
  # require_bundle_gems and sets the Jets.env to whatever the JETS_ENV is
  # at the time.
  #
  # Defaults to development when not set.
  def set_jets_env_for_deploy_command!
    command, env = thor_args[0..1]
    return unless command == "deploy"
    env = nil if env&.starts_with?('-')
    ENV['JETS_ENV'] = env ? env : 'development'
  end

  # thor_args normalized the args Array to work with our Thor command
  # subclasses.
  # 1. The namespace is stripe
  # 2. Help is shifted in front if a help flag is detected
  def thor_args
    args = @given_args.clone

    help_args = args & help_flags
    unless help_args.empty?
      # Allow using help flags at the end of the command to trigger help menu
      args -= help_flags # remove "help" and help flags from args
      args[0] = meth # first command will always be the meth now since
        # we removed the help flags
      args.unshift("help")
      args.compact!
      return args
    end

    # reassigns the command without the namespace if reached here
    args[0] = meth
    args.compact
  end

  ALIASES = {
    "g"  => "generate",
    "c"  => "console",
    "s"  => "server",
    "db" => "dbconsole",
  }
  def full_command
    # Removes any args that starts with -, those are option args.
    # Also remove "help" flag.
    args = @given_args.reject {|o| o =~ /^-/ } - help_flags
    command = args[0] # first argument should always be the command
    command = ALIASES[command] || command
    Jets::Commands::Base.autocomplete(command)
  end

  # 1. look up Thor tasks
  # 2. look up Rake tasks
  # 3. help menu with all commands when both Thor and Rake tasks are not found
  def lookup(full_command)
    thor_task_found = Jets::Commands::Base.namespaced_commands.include?(full_command)
    if thor_task_found
      return Jets::Commands::Base.klass_from_namespace(namespace)
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

    unless rake_list.empty?
      shell.say "\nCommands via rake:"
      shell.print_table(rake_list, :indent => 2, :truncate => true)
    end

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
Add -h to any of the commands for more help.  Examples:

  jets call -h
  jets routes -h
  jets deploy -h
  jets status -h
  jets dynamodb:create -h
  jets db:create -h

EOL
  end

end
