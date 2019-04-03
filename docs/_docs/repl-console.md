---
title: REPL Console
nav_order: 10
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

{% include prev_next.md %}