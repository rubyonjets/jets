require 'fileutils'
require 'erb'

# bin/jets generate migration exam_problems --partition-key id:string
class Jets::Generate::Migration
  def initialize(table_name, options)
    @table_name = table_name
    @options = options
  end

  def run
    puts "Creating migration"
    return if @options[:noop]
    pp @options
    create_migration
  end

  def create_migration
    puts "TODO: implement create_migration"
    migation_file = "timestamp-#{@table_name}.rb"
    migration_path = "#{Jets.root}db/migrate/#{migation_file}"
    dir = File.dirname(migration_path)
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    IO.write(migration_path, migration_code)
  end

  def migration_code
    @table_name = table_name
    @key_schema = pp(key_schema)
    @attribute_definitions = pp(attribute_definitions)
    result = ERB.new(template, nil, "-").result(binding)
  end

  def table_name
    random = (0...3).map { (65 + rand(26)).chr }.join.downcase # for testing
    [Jets::Config.project_namespace, @table_name, random].join('-')
  end

  def key_schema
    [
      {
        attribute_name: 'year',
        key_type: 'HASH'  #Partition key
      },
      {
        attribute_name: 'title',
        key_type: 'RANGE' #Sort key
      }
    ]
  end

  def attribute_definitions
    [
      {
        attribute_name: 'year',
        attribute_type: 'N'
      },
      {
        attribute_name: 'title',
        attribute_type: 'S'
      },
    ]
  end

  # http://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/dynamo-example-create-table.html
  def template
    <<-EOL
require 'aws-sdk-dynamodb'  # v2: require 'aws-sdk'

# Create dynamodb client
dynamodb = Aws::DynamoDB::Client.new

# Create table Movies with year (integer) and title (string)
params = {
    table_name: '<%= @table_name %>',
    key_schema: <%= @key_schema %>,
    attribute_definitions: <%= @attribute_definitions %>,
    provisioned_throughput: {
        read_capacity_units: 10,
        write_capacity_units: 10
  }
}

begin
  result = dynamodb.create_table(params)

  puts 'Created table. Status: ' +
        result.table_description.table_status;
rescue  Aws::DynamoDB::Errors::ServiceError => error
  puts 'Unable to create table:'
  puts error.message
end
EOL
  end
end
