---
title: REPL Console
---

You can test things out in a REPL console:

    $ jets console
    >> Post.table_name
    => "posts"
    >> ActiveRecord::Base.connection.tables
    => ["schema_migrations", "ar_internal_metadata", "posts"]
    >> Jets.env
    => "development"
    >>

