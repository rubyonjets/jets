class Jets::Generate::Help
  class << self
    def migration
<<-EOL
Generates a migration file which can be used to create a DynamoDB table.  To run the migration file `ruby db/migrate/path-to-migration.rb`.

By default, the table will be created with the project namespace. For example, given your project is called "proj", the env is called "dev", and you create a table called "posts".  The DynamoDB full table name will be "proj-dev-posts".  You can change this behavior with the `--namespace mynamespace` option.  If you would like no namespace at all, use `--namespace ''`.

Examples:

$ jets generate migration posts --partition-key id:string

$ jets generate migration posts --partition-key id:string --namespace mynamespace

$ jets generate migration posts --partition-key id:string --namespace '' # no namespace

$ jets generate migration comments --partition-key post_id:string --sort-key created_at:string --namespace proj-dev
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
