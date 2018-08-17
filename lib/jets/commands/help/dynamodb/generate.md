Generates a migration file which can be used to create a DynamoDB table.  To run the migration file use `jets dynamodb:migrate`.

The table name will have a namespace. For example, if your project is called `demo`, the environment is `development`, and you create a table called `posts`.  The DynamoDB full table name will be `demo-dev-posts`.  You can change this behavior by editing your `config/dynamodb.yml` and adjusting the `table_namespace` value.

DynamoDB tables support certain types of attribute types. The CLI will parse the `--partition-key` option and use the second part of the option to map it to the underlying DynamoDB type using this mapping.

```ruby
ATTRIBUTE_TYPE_MAP = {
  'string' => 'S',
  'number' => 'N',
  'binary' => 'B',
  's' => 'S',
  'n' => 'N',
  'b' => 'B',
}
```

For example, `--partition-key id:string`  maps 'string' to 's'.  More info on DynamoDB types is available at the ruby aws-sdk docs: [Aws::DynamoDB::Types::AttributeDefinition](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Types/AttributeDefinition.html)

## Examples

    $ jets dynamodb:generate create_posts --partition-key id # default attribute type is string
    $ jets dynamodb:generate create_posts --partition-key id:number # attribute type will be number
    $ jets dynamodb:generate create_comments --partition-key post_id:string --sort-key created_at:string

## Running migrations

    $ jets dynamodb:migrate path/to/migration
    $ jets dynamodb:migrate dynamodb/migrate/20171112162404-create_articles_migration.rb

To add global secondary indexes:

    $ jets dynamodb:generate update_comments --partition-key user_id:string --sort-key created_at:string

To run:

    $ jets dynamodb:migrate dynamodb/migrate/20171112161530-create_posts_migration.rb

## Conventions

A create_table or update_table migration file is generated based name you provide.  If `update` is included in the name then an update_table migration table is generated. If `create` is included in the name then a create_table migration table is generated.

The table_name is also inferred from the migration name you provide.  Examples:

    $ jets dynamodb:generate create_posts # table_name: posts
    $ jets dynamodb:generate update_comments # table_name: comments

You can override both of these conventions:

    $ jets dynamodb:generate create_my_posts --table-name posts
    $ jets dynamodb:generate my_posts --table-action create_table --table-name posts
    $ jets dynamodb:generate my_posts --table-action update_table --table-name posts
