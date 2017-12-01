Generates migration in db/migrate

Examples:

$ jets db:generate create_articles title:string user_id:integer

$ jets db:generate AddTitleBodyToPost title:string body:text published:boolean

This tasks simply delegates to Rails `rails generate migration`.  For more examples: `rails generate migration -h`.
