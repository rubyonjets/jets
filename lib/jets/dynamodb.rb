class Jets::Dynamodb < Jets::Command
  autoload :Help, 'jets/dynamodb/help'
  autoload :Migrate, 'jets/dynamodb/migrate'

  desc "migrate [path]", "Runs migrations"
  long_desc Help.migrate
  def migrate(path)
    Migrate.new(path, options).run
  end

  desc "generate [name]", "Creates a migration for a DynamoDB table"
  long_desc Help.generate
  option :partition_key, default: "id:string:hash", desc: "table's partition key"
  option :sort_key, default: nil, desc: "table's sort key"
  # option :type, default: 'dynamodb', desc: "dynamodb or relational"
  def generate(name)
    DynamodbModel::Migration::Generator.new(name, options).generate
  end
end
