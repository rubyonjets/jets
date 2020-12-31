---
title: Structure
---

The `jets new` command generates a new project with the following directory structure:

    .
    ├── app
    │   ├── controllers
    │   ├── helpers
    │   ├── javascript
    │   ├── jobs
    │   ├── models
    │   └── views
    ├── bin
    ├── config
    ├── db
    ├── public
    └── spec

The table below states the purpose of each directory:

File / Directory  | Description
------------- | -------------
app/controllers  | Contains controller code that handles API Gateway web requests. For more info refer to [controllers]({% link _docs/controllers.md %})
app/functions  | Contains simple functions.  For more info refer to [functions]({% link _docs/functions.md %}).
app/helpers  | Contains helpers methods that can be used to assist view code.
app/javascript  | Contains javascript, CSS, and images files that webpacker compiles. Javascript lives in `javascript/packs`, CSS in `javascript/src` and images in `javascript/images`. Refer to [webpacker](https://github.com/rails/webpacker) for more info.
app/jobs  | Contains job definitions. This code usually executes on a scheduled basis asynchronously outside of the request-response cycle.  For more info refer to the [jobs docs]({% link _docs/jobs.md %})
app/models  | Contains model definitions, usually classes that interact with a database via ActiveRecord or some other ORM.
app/shared  | Contains shared resources. Refer to [Shared Resources]({% link _docs/shared-resources.md %}).
app/views  | Contains view code, usually HTML pages and forms.
bin  | Contains helper executables.
config  | Contains configuration files for databases, routes, webpacker, etc.  Application-wide configurations are set in [config/application.rb]({% link _docs/app-config.md %}).
config/environments | Contains environment-specific application-wide configurations (`development.rb`, `production.rb`, etc).
db  | Contains database migrations. ActiveRecord migrations live under `db/migrate` and the Dynamodb migrations are in `db/dynamodb`.
public  | Contains static files meant to be served "as-is".
spec | Contains tests.

