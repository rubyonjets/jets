require "jets"
require "rails/generators"
require "rails/generators/active_record/migration/migration_generator"

class Jets::Db
  autoload :Tasks, 'jets/db/tasks'
  autoload :Help, 'jets/db/help'

  def initialize(options)
    @options = options
  end

  def run_command(*args)
    # "jets db generate help" results in args:
    #   ["help", "generate"]
    if args[0] == "help" && args[1] == "generate"
      # TODO: figure out how to print help via Thor itself for jets db generate help
      print_help_generate
      return
    end

    # generate is the only method that does not delegate to the ActiveRecord
    # rake tasks.
    if args[0] == "generate"
      args.shift # remove generate
      # Example:
      #   args: ["generate", "create_articles", "title:string"]
      #   args: ["create_articles", "title:string"]
      generator = ActiveRecord::Generators::MigrationGenerator.new(args)
      generator.create_migration_file
    else
      command = "bundle exec rake db:#{args.join(':')}"
      puts "=> #{command}".colorize(:green)
      system command
    end
  end

  def print_help_generate
    puts Help.generate
  end
end
