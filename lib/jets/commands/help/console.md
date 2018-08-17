## Example

    $ jets console
    >> Post.table_name
    => "posts"
    >> ActiveRecord::Base.connection.tables
    => ["schema_migrations", "ar_internal_metadata", "posts"]
    >> Jets.env
    => "development"
    >>
