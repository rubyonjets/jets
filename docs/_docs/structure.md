---
title: Structure
---

The `jets new` command generates the initial folder structure for a Jets project. The structure looks like this:

```sh
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
```

The table below covers the purpose of each folder and file.

File / Directory  | Description
------------- | -------------
app/controllers  | Contains controller code that handles API Gateway web requests. For more info refer to [controllers]({% link _docs/controllers.md %})
app/helpers  | Contains helpers methods that can be used to assist view code.
app/javascript  | Contains javascript, css and images files that webpacker compiles for you. The javascript files live in `javascript/packs`, the css in `javascript/src` and images in `javascript/images`. Refer to [webpacker](https://github.com/rails/webpacker) for more info.
app/jobs  | Contains job code. This code usually execute on a scheduled basis asychronously outside of the request response cycle.  For more info refer to [workers]({% link _docs/workers.md %})
app/models  | Contains model code, usually classes that interact with database.
app/views  | Contains view code, usually html pages and forms.
bin  | Contains helper executables that helps jets run.
config  | Your application's configurations. Where to configure the application's settings, database, routes, webpacker settings, etc.  Application wide configurations are set in [config/application.rb]({% link _docs/app-config.md %}).
db  | Contains database migrations. The ActiveRecord migrations live under `db/migrate` and the Dynamodb migrations are under `db/dynamodb`.
public  | Contains static files meant to be served straight up.
spec | Contains unit tests.

<a id="prev" class="btn btn-basic" href="{% link _docs/install.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/local-server.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
