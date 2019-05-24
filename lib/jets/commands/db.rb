module Jets::Commands
  class Db < Jets::Commands::Base
    desc "generate", "Creates a migration to change a db table"
    long_desc Help.text('db:generate')
    def generate(*args)
      require "rails/generators"
      require "rails/generators/active_record/migration/migration_generator"

      generator = ActiveRecord::Generators::MigrationGenerator.new(args)
      generator.create_migration_file
    end
  end
end
