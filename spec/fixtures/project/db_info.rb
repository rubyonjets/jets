require "jets"
require "pp"
require "colorize"

def report_print(table, method_name)
  results = table.send(method_name)
  case results
  when Array
    puts "#{method_name}:"
    puts "  #{results.map(&:to_h).inspect}"
  when Struct
    puts "#{method_name}:"
    puts "  #{results.inspect}"
  when String
    puts "#{method_name}: #{results}"
  when NilClass
    puts "#{method_name}: #{results.inspect}"
  else
    puts results.class
    pp results
    puts "dont what it is"
  end
end

# main

Jets.boot
db = DynamodbModel::Item.db # uses the appropriate dynamodb endpoint
  # so we can test with local DynamoDB or a live on on AWS

# summary of the dynamodb tables, useful for local dynamodb
db.list_tables.table_names.each do |table_name|
  puts "Table: #{table_name.colorize(:green)}"
  resp = db.describe_table(table_name: table_name)
  table = resp.table
  report_print(table, "table_arn")
  report_print(table, "key_schema")
  report_print(table, "attribute_definitions")
  report_print(table, "local_secondary_indexes")
  report_print(table, "global_secondary_indexes")
  # report_print(table, "provisioned_throughput")
end
