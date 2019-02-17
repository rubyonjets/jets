---
title: Database ActiveRecord
---

Jets also supports ActiveRecord and currently the PostgreSQL and MySQL.  This is configured with your `Gemfile` and `config/database.yml`.

## Migrations

Here's an example of creating migrations:

    jets db:generate create_posts # generates migration
    jets db:migrate

Both can DynamoDB and ActiveRecord can coexist in the same application.

<a id="prev" class="btn btn-basic" href="{% link _docs/database-dynamodb.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/debugging-tips.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
