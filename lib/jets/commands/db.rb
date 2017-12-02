require "rails/generators"
require "rails/generators/active_record/migration/migration_generator"

module Jets::Commands
  class Db < Jets::Commands::Base
    autoload :Tasks, 'jets/commands/db/tasks'

    desc "generate", "Creates a migration to change a db table"
    long_desc Help.text('db:generate')
    def generate(*args)
      generator = ActiveRecord::Generators::MigrationGenerator.new(args)
      generator.create_migration_file
    end
  end
end
