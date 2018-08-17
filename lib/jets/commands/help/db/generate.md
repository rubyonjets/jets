Generates migration in `db/migrate`

## Examples

    jets db:generate create_articles title:string user_id:integer
    jets db:generate AddTitleBodyToPost title:string body:text published:boolean

This task delegates to Rails `rails generate migration`.  For more examples, refer to the [Active Record Migrations Rails Guide](https://edgeguides.rubyonrails.org/active_record_migrations.html).