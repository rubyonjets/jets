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
    # Needs to be at the beginning to avoid boot_jets which causes some load errors
    if version_requested?
      puts Jets.version
      return
    end

    # Need to boot jets at this point for commands like: jets routes, deploy, console, etc to work
    boot_jets
    command_class = lookup(full_command)
    if command_class
      command_class.perform(full_command, thor_args)
    else
      main_help
    end
  end

  # The commands new and help do not call Jets.boot. Main reason is that Jets.boot should be run in a Jets project.
  #
  #   * jets new - need to generate a project outside a project folder.
  #   * jets help - don't need to be in a project folder general help.
  #
  # When you are inside a project folder though, more help commands are available and displayed.
  #
  def boot_jets
    set_jets_env_from_cli_arg!
    command = thor_args.first
    unless %w[new help].include?(command)
      Jets::Turbo.new.charge # handles Afterburner mode
      Jets.boot
    end
  end

  def version_requested?
    #   jets --version
    #   jets -v
    version_flags = ["--version", "-v"]
    @given_args.length == 1 && !(@given_args & version_flags).empty?
  end

  # Adjust JETS_ENV before boot_jets is called for the `jets deploy` command.  Must do this early in the process
  # before Jets.boot because because `bundler_require` is called as part of the bootup process. It sets the Jets.env
  # to whatever the JETS_ENV is at the time to require the right bundler group.
  #
  # Defaults to development when not set.
  def set_jets_env_from_cli_arg!
    # Pretty tricky, we need to use the raw @given_args as thor_args eventually calls Commands::Base#eager_load!
    # which uses Jets.env before we get a chance to override ENV['JETS_ENV']
    command, env = @given_args[0..1]
    return unless %w[deploy delete].include?(command)
    env = nil if env&.starts_with?('-')
    return unless env
    ENV['JETS_ENV'] = env ? env : 'development'
  end

  # thor_args normalized the args Array to work with our Thor command
  # subclasses.
  # 1. The namespace is stripe
  # 2. Help is shifted in front if a help flag is detected
  def thor_args
    args = @given_args.clone

    # jets generate is a special command requires doesn't puts out the help menu automatically when
    # `jets generate` is called without additional args.  We'll take it over early and fix it here.
    generate = full_command == "generate"

    if generate && ((args.size == 1 || help_flags.include?(args.last)) || args.size == 2)
      puts Jets::Generator.help
      exit
    end

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

  def meth
    return nil unless full_command

    if full_command.include?(':')
      full_command.split(':').pop
    else
      full_command
    end
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

    return unless jets_project?
    rake_task_found = Jets::Commands::RakeCommand.namespaced_commands.include?(full_command)
    if rake_task_found
      return Jets::Commands::RakeCommand
    end
  end

  def jets_project?
    File.exist?("config/application.rb")
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

  def main_help
    shell = Thor::Shell::Basic.new
    shell.say "Commands:"
    shell.print_table(thor_list, :indent => 2, :truncate => true)

    if jets_project? && !rake_list.empty?
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
