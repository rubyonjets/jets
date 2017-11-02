# TODO: implement scaffolding and add notes to the README

### Scaffolding

You can also use `jets generate scaffold` to quickly generate basic CRUD code.  Example:

```sh
jets generate scaffold Post name:string title:string content:text
```

The scaffold creates a migration in `db/migrate` for DynamoDB. You'll need to run migrations to create the DynamoDB table.

```
jets db:migrate
```

Next, deploy the app.

```sh
jets deploy
```

