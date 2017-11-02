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
    # pp @options
    create_migration
  end

  def create_migration
    migation_file = "timestamp-#{@table_name}.rb"
    migration_path = "#{Jets.root}db/migrate/#{migation_file}"
    dir = File.dirname(migration_path)
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    IO.write(migration_path, migration_code)
  end

  def migration_code
    @table_name = table_name
    @key_schema = key_schema.inspect
    @attribute_definitions = attribute_definitions.inspect
    result = ERB.new(template, nil, "-").result(binding)
  end

  def table_name
    random = (0...3).map { (65 + rand(26)).chr }.join.downcase # for testing
    [Jets::Config.project_namespace, @table_name, random].join('-')
  end

  # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Types/KeySchemaElement.html
  # Valid key types:
  # {
  #   attribute_name: "KeySchemaAttributeName", # required
  #   key_type: "HASH", # required, accepts HASH, RANGE
  # }
  def key_schema
    partition_key_name, _, partition_key_type = @options[:partition_key].split(':')
    partition_key_type = "hash" if partition_key_type.nil?
    partition_key_type = partition_key_type.downcase

    partition_key = {
      attribute_name: partition_key_name,
      key_type: partition_key_type.upcase
    }

    key_schema = [partition_key] # partition_key is required

    # sort_key is optional
    sort_key_option = @options[:sort_key]
    if sort_key_option
      sort_key_name, _, sort_key_type = sort_key_option.split(':')
      sort_key = {
        attribute_name: sort_key_name,
        key_type: sort_key_type.upcase # Valid Sort key: HASH or RANGE
      }
      key_schema << sort_key
    end

    key_schema
  end

  # http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Types/AttributeDefinition.html
  # {
  #   attribute_name: "KeySchemaAttributeName", # required
  #   attribute_type: "S", # required, accepts S, N, B
  # }
  ATTRIBUTE_TYPE_MAP = {
    'string' => 'S',
    'number' => 'N',
    'binary' => 'B',
    's' => 'S',
    'n' => 'N',
    'b' => 'B',
  }
  def attribute_definitions
    partition_key_name, attribute_type, _ = @options[:partition_key].split(':')
    attribute_type = "string" if attribute_type.nil?
    attribute_type = ATTRIBUTE_TYPE_MAP[attribute_type]

    attribute_definitions = [
      {
        attribute_name: partition_key_name,
        attribute_type: attribute_type
      }
    ]

    # sort_key is optional
    sort_key_option = @options[:sort_key]
    puts "sort_key_option #{sort_key_option.inspect}"
    if sort_key_option
      sort_key_name, sort_attribute_type,  = sort_key_option.split(':')
      sort_key = {
        attribute_name: sort_key_name,
        attribute_type: ATTRIBUTE_TYPE_MAP[sort_attribute_type]
      }
      attribute_definitions << sort_key
    end

    pp attribute_definitions

    attribute_definitions
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
        read_capacity_units: 5,
        write_capacity_units: 5
  }
}

begin
  result = dynamodb.create_table(params)

  puts 'DynamoDB Table: <%= @table_name %> Status: ' +
        result.table_description.table_status;
rescue  Aws::DynamoDB::Errors::ServiceError => error
  puts 'Unable to create table:'
  puts error.message
end
EOL
  end
end
