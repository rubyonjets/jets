---
title: Database ActiveRecord
nav_order: 40
---

Jets also supports ActiveRecord and currently the PostgreSQL and MySQL.  This is configured with your `Gemfile` and `config/database.yml`.

## Migrations

Here's an example of creating migrations:

    jets db:generate create_posts # generates migration
    jets db:migrate

Both DynamoDB and ActiveRecord can coexist in the same application.

{% include prev_next.md %}
