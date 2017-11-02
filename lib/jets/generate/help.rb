class Jets::Generate::Help
  class << self
    def migration
<<-EOL
Generates a migration file which can be used to create a DynamoDB table.  To run the migration file `ruby db/migrate/path-to-migration.rb`.

By default, the table will be created with the project namespace. For example, given your project is called "proj", the env is called "dev", and you create a table called "posts".  The DynamoDB full table name will be "proj-dev-posts".  You can change this behavior with the `--namespace mynamespace` option.  If you would like no namespace at all, use `--namespace ''`.

For the `--partition-key` option, DynamoDB tables support certain types of attribute types. More info here: http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Types/AttributeDefinition.html

The cli will parse the --partition-key option and use the second part of the option to map it to the underlying DynamoDB type using this mapping:

  ATTRIBUTE_TYPE_MAP = {
    'string' => 'S',
    'number' => 'N',
    'binary' => 'B',
    's' => 'S',
    'n' => 'N',
    'b' => 'B',
  }

For example, --partition-key id:string will map 'string' to 's'.

For the `--sort-key` option, DynamoDB support 2 options: HASH or RANGE. More info: http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Types/KeySchemaElement.html

For example, --sort-key created_at:hash will map 'hash' to 'HASH'.

Examples:

$ jets generate migration posts --partition-key id # default attribute type is string, default key_type is hash

$ jets generate migration posts --partition-key id:string:hash

$ jets generate migration posts --partition-key id:string:hash --namespace mynamespace

$ jets generate migration posts --partition-key id:string:hash --namespace '' # no namespace

$ jets generate migration comments --partition-key post_id:string:hash --sort-key created_at:string:range --namespace proj-dev
EOL
    end

    def scaffold
<<-EOL
Generates scaffold CRUD files for the project.

Example:

$ jets generate scaffold posts id:string title:string description:string
EOL
    end
  end
end
