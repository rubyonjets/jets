---
title: CRUD HTML ActiveRecord
---

The easiest way to get a CRUD HTML ActiveRecord app running by using the scaffold.

## Summary

Here's a summary of the commands:

    jets new demo
    cd demo
    jets generate scaffold post title:string
    edit .env.development # adjust to your local database creds
    jets db:create db:migrate
    jets server # Check out http://localhost:8888/posts

Let's go through the commands in a little more detail.

## Generate a new project

    $ jets new demo
    Creating new project called demo.
          create  demo/app/controllers/application_controller.rb
          create  demo/app/helpers/application_helper.rb
          create  demo/app/jobs/application_job.rb
    ...
    ================================================================
    Congrats  You have successfully created a Jets project.

    Cd into the project directory:
      cd demo

    To start a server and test locally:
      jets server # localhost:8888 should have the Jets welcome page

    Scaffold example:
      jets generate scaffold post title:string body:text published:boolean

    To deploy to AWS Lambda:
      jets deploy
    $

## CRUD Scaffold

    $ cd demo
    $ jets generate scaffold post title:string
          invoke  active_record
          create    db/migrate/20180810215214_create_posts.rb
          create    app/models/post.rb
          invoke  resource_route
           route    resources :posts
          invoke  scaffold_controller
          create    app/controllers/posts_controller.rb
          invoke    erb
          create      app/views/posts
          create      app/views/posts/index.html.erb
          create      app/views/posts/edit.html.erb
          create      app/views/posts/show.html.erb
          create      app/views/posts/new.html.erb
          create      app/views/posts/_form.html.erb
          invoke    helper
          create      app/helpers/posts_helper.rb
    $

This generates a Post ActiveRecord model and the view code for a simple CRUD app.

## Edit Database Config

In the next step, we'll update the .env.development and set the local database config. For this step, it is helpful to take a quick look at `database.yml`:

```yaml
default: &default
  adapter: postgresql
  encoding: utf8
  pool: <%= ENV["DB_POOL"] || 5  %>
  database: <%= ENV['DB_NAME'] || 'demo_dev' %>
  username: <%= ENV['DB_USER'] || ENV['USER'] %>
  password: <%= ENV['DB_PASS'] %>
  host: <%= ENV["DB_HOST"] %>
  url: <%= ENV['DATABASE_URL'] %> # takes higher precedence than other settings

development:
  <<: *default
  database: <%= ENV['DB_NAME'] || 'demo_dev' %>
...
```

So we can adjust environment variables to configure a local database. My `.env.development` to looks like this:

.env.development:

    DATABASE_URL=postgres://ec2-user@localhost/demo_dev

If you have a password the format would look like this:

    DATABASE_URL=postgres://ec2-user:mypassword@localhost/demo_dev

## Create DB and Tables

    $ jets db:create db:migrate
    Created database 'demo_dev'
    Created database 'demo_test'
    == 20180810215214 CreatePosts: migrating ======================================
    -- create_table(:posts)
       -> 0.0062s
    == 20180810215214 CreatePosts: migrated (0.0062s) =============================
    $

## Start the Server

Let's start the server.

    $ jets server
    => bundle exec shotgun --port 8888 --host 127.0.0.1
    Jets booting up in development mode!
    == Shotgun/WEBrick on http://127.0.0.1:8888/
    [2018-08-10 23:01:05] INFO  WEBrick 1.4.2
    [2018-08-10 23:01:05] INFO  ruby 2.5.1 (2018-03-29) [x86_64-linux]
    [2018-08-10 23:01:05] INFO  WEBrick::HTTPServer#start: pid=13999 port=8888

## Check out the CRUD App

1. Go to [http://localhost:8888/posts](http://localhost:8888/posts)
2. Create some items
3. You should end up have some posts that look something like below:

![](/img/docs/crud/posts-index.png)