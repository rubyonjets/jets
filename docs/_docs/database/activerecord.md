---
title: Database ActiveRecord
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

It's also worth noting that AWS clients provided by the [Jets::AwsServices](https://github.com/boltops-tools/jets/blob/master/lib/jets/aws_services.rb) module similarly leverage the Lambda Execution context. IE: The clients get reused between lambda calls.

## RDS Database Support

When creating a database on AWS RDS, you can select between mySQL and PostgreSQL.
When you've created an RDS it will create/use a VPC with at 3 subnets.

To use it with Jets you'll need to do several things.
Create a lambda security group for lambda functions. No Inbound rules.
Create a cloudformation security group for lambda functions. Inbound rules would be HTTPS from the lambda security group.
[Create an endpoint](https://docs.aws.amazon.com/vpc/latest/userguide/vpce-interface.html#create-interface-endpoint) to allow the lambda security group to cloud formation.
Create a security group to allow traffic from the lambda security group to the RDS VPC for the DB Engine. Inbound rules for PGSQL would be from TCP/5432 - Postgresql from the lambda security group.

Add the vpc_config for the lambda functions in config/application.rb:

    config.function.vpc_config = {
      security_group_ids: %w[ <lambda security group> ],
      subnet_ids: %w[ <rds subnet 1> <rds subnet 2> <rds subnet 3> ]
    }

## Aurora Database Support

Aurora should work since it is MySQL compatible. Note, with Aurora, your Lambda functions must be configured with a VPC.

