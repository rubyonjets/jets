module Jets::Commands
  class Dynamodb < Jets::Commands::Base
    desc "migrate [path]", "Runs migrations"
    long_desc Help.text('dynamodb:migrate')
    def migrate(path)
      Migrator.new(path, options).run
    end

    desc "generate [name]", "Creates a migration for a DynamoDB table"
    long_desc Help.text('dynamodb:generate')
    option :partition_key, default: "id:string:hash", desc: "table's partition key"
    option :sort_key, default: nil, desc: "table's sort key"
    option :table_name, desc: "override the the conventional table name"
    option :table_action, desc: "create_table or update_table. Defaults to convention based on the name of the migration."
    def generate(name)
      Dynomite::Migration::Generator.new(name, options).generate
    end
  end
end
