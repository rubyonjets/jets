class Jets::Generate::Help
  class << self
    def migration
<<-EOL
Generates a migration file which can be used to create a DynamoDB table.  To run the migration file use `jets db:migrate`.

The table name will have a namespace. For example, given your project is called "proj", the env is called "dev", and you create a table called "posts".  The DynamoDB full table name will be "proj-dev-posts".  You can change this behavior by editing your config/dynamodb.yml.

For the `--partition-key` option, DynamoDB tables support certain types of attribute types. The cli will parse the --partition-key option and use the second part of the option to map it to the underlying DynamoDB type using this mapping.

  ATTRIBUTE_TYPE_MAP = {
    'string' => 'S',
    'number' => 'N',
    'binary' => 'B',
    's' => 'S',
    'n' => 'N',
    'b' => 'B',
  }

For example, --partition-key id:string will map 'string' to 's'.  More info here: http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Types/AttributeDefinition.html

Examples:

$ jets generate migration posts --partition-key id # default attribute type is string

$ jets generate migration posts --partition-key id:number # attribute type will be number

$ jets generate migration comments --partition-key post_id:string --sort-key created_at:string
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
