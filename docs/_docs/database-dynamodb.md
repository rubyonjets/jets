---
title: Database DynamoDB
---

Jets supports DynamoDB. Here's an example:

````
jets dynamodb:generate create_posts # generates migration
jets dynamodb:migrate dynamodb/migrate/20171112194549-create_posts_migration.rb # run migration. replace with your timestamp
```

If you are using DynamoDB it can be useful to use DynamoDB Local, just like you would use a local SQL server. It's simply a jar file you download and run. Here's a [DynamoDB Local Setup Walkthrough](https://github.com/tongueroo/jets/wiki/Dynamodb-Local-Setup-Walkthrough) that takes about 5 minutes.

<a id="prev" class="btn btn-basic" href="{% link _docs/deploy.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/database-activerecord.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
