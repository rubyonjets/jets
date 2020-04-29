---
title: Database ActiveRecord
nav_order: 54
---

Jets also supports ActiveRecord and currently the PostgreSQL and MySQL.  This is configured with your `Gemfile` and `config/database.yml`.

### Database Adapter

The default database adapter configured by [jets new](https://rubyonjets.com/reference/jets-new/) is MySQL.

    jets new demo

If you would like to use PostgreSQL instead, use:

    jets new demo --database=postgresql

## Create DB

Before you start making migrations, create the development and test databases:

```
jets db:create
```

## Migrations

Here's an example of creating migrations:

    jets db:generate create_posts # generates migration
    jets db:migrate

Both DynamoDB and ActiveRecord can coexist in the same application.

## Database Connections and Lambda Execution Context

On traditional long-running servers, usually, when a web server starts up a pool of DB connections are created. The connection pool is kept in shared memory or “class” memory. Web requests share this connection pool. This strategy prevents the number of DB connections from endlessly increasing and exhausting the connection limit for the DB server.

On AWS Lambda, there's something called the [Lambda Execution Context](https://docs.aws.amazon.com/lambda/latest/dg/running-lambda-code.html).  The Lambda Execution Context gets reused between lambda function runs. Jets establishes the DB connection within the Lambda Execution Context outside the handler. So DB connections get reused between subsequent lambda function runs. This prevents DB connections from ever-increasing. The AWS docs specifically point out to use the Lambda Execution Context for things like establishing DB connections.

It's also worth noting that AWS clients provided by the [Jets::AwsServices](https://github.com/tongueroo/jets/blob/master/lib/jets/aws_services.rb) module similarly leverage the Lambda Execution context. IE: The clients get reused between lambda calls.

## Aurora Database Support

Aurora should work since it is MySQL compatible. Note, with Aurora, your Lambda functions must be configured with a VPC.

{% include prev_next.md %}
