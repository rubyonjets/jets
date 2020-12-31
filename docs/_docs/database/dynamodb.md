---
title: Database DynamoDB
---

Jets supports DynamoDB via [Dynomite](https://github.com/tongueroo/dynomite).

## Migrations

Here's an example of creating migrations:

    jets dynamodb:generate create_posts # generates migration
    jets dynamodb:migrate dynamodb/migrate/20171112194549-create_posts_migration.rb # run migration. replace with your timestamp

If you are using DynamoDB it can be useful to use DynamoDB Local, just like you would use a local SQL server. It's simply a jar file you download and run. Here's a [DynamoDB Local Setup Walkthrough](https://github.com/boltops-tools/jets/wiki/Dynamodb-Local-Setup-Walkthrough) that takes about 5 minutes.

