## Examples

    $ jets new demo
    Creating a new Jets project called demo.
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

## Mode Option

The `--mode` is a notable option. With it, you can generate different starter Jets projects. Examples:

    jets new demo --mode html # default
    jets new api --mode api
    jets new cron --mode job

* The html mode generates a starter app useful for html web application.
* The api mode is useful for building an API.
* The job mode creates a very lightweight project. It is useful when you just need to run a Lambda function.

## Repo Option
Use the `--repo` flag to clone an example project from GitHub instead.  With this flag, jets new command clones a jets project repo from GitHub:

    $ jets new blog --repo tongueroo/tutorial
    $ jets new todos --repo tongueroo/todos
    $ jets new whatever --repo user/repo # any github repo
