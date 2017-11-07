class CreatePostsMigration < DynamodbModel::Migration
  def up
    create_table :posts do |t|
      t.partition_key "id" # required
      t.provisioned_throughput(5) # sets both read and write, defaults to 5 when not set

      # Instead of using partition_key and sort_key you can set the
      # key schema directly also
      # t.key_schema([
      #     {attribute_name: "id", :key_type=>"HASH"},
      #     {attribute_name: "created_at", :key_type=>"RANGE"}
      #   ])
      # t.attribute_definitions([
      #   {attribute_name: "id", attribute_type: "N"},
      #   {attribute_name: "created_at", attribute_type: "S"}
      # ])

      # other ways to set provisioned_throughput
      # t.provisioned_throughput(:read, 10)
      # t.provisioned_throughput(:write, 10)
      # t.provisioned_throughput(
      #   read_capacity_units: 5,
      #   write_capacity_units: 5
      # )
    end
  end
end

# Note: table name created will be namespaced based on
# DynamodbModel::Migration.table_namespace.  This can be set in
# config/dynamodb.yml
#
# development:
#   table_namespace: "mynamespace"
#
# This results in:
#   create_table "posts" => table name: "mynamespace-posts"
#
# When you're in a in Jets project you can set the namespace based on
# Jets.config.table_namespace, which is based on the project name and
# a short version of the environment.  Example:
#
# `config/dynamodb.yml`:
# development:
#   table_namespace: <%= Jets.config.table_namespace %>
#
# If your project_name is proj and environment is production:
#   create_table "posts" => table name: "proj-prod-posts"
#
# If your project_name is proj and environment is staging:
#   create_table "posts" => table name: "proj-stag-posts"
#
# If your project_name is proj and environment is development:
#   create_table "posts" => table name: "proj-dev-posts"
#
# If the table_namespace is set to a blank string or nil, then a namespace
# will not be prepended at all.
