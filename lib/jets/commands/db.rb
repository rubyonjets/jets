require "rails/generators"
require "rails/generators/active_record/migration/migration_generator"

class Jets::Commands::Db < Jets::Commands::Base
  autoload :Help, 'jets/commands/db/help'
  autoload :Tasks, 'jets/commands/db/tasks'

  desc "generate", "Creates a migration to change a db table"
  long_desc Jets::Commands::Db::Help.generate
  def generate(*args)
    generator = ActiveRecord::Generators::MigrationGenerator.new(args)
    generator.create_migration_file
  end
end
