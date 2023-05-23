## Example

    $ jets console
    >> Post.table_name
    => "posts"
    >> ActiveRecord::Base.connection.tables
    => ["schema_migrations", "ar_internal_metadata", "posts"]
    >> Jets.env
    => "development"
    >>

## Use .env.development.remote

To use the remote values also in the `jets console` you can use the `JETS_ENV_REMOTE=1` env variable. Example:

    JETS_ENV_REMOTE=1 jets console

More info at [Env Files](http://rubyonjets.com/docs/env-files/)