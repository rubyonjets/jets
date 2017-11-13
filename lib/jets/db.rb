require "jets"
require "rails/generators"
require "rails/generators/active_record/migration/migration_generator"

class Jets::Db
  autoload :Tasks, 'jets/db/tasks'

  def initialize(options)
    @options = options
  end

  def run_command(*args)
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
end
