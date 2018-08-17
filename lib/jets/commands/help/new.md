## Examples

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
      jets generate scaffold Post title:string body:text published:boolean

    To deploy to AWS Lambda:
      jets deploy
    $

Use the `--repo` flag to clone an example project from GitHub instead.  With this flag, jets new command clones a jets project repo from GitHub:

    $ jets new blog --repo tongueroo/tutorial
    $ jets new todos --repo tongueroo/todos
    $ jets new whatever --repo user/repo # any github repo
