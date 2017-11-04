# DynamoDB Local Walkthrough with Jets

## Install
```sh
brew cask install dynamodb-local
dynamodb-local
```

dynamodb-local is now running on port 8000.

## Configure config/database.yml

`config/database.yml`:

```yaml
development:
  endpoint: http://localhost:8000 # uncomment, if you want to use a live AWS DynamoDB database
test:
  endpoint: http://localhost:8000 # uncomment, if you want to use a live AWS DynamoDB database
```

## Create Tables

```sh
jets generate migration posts
jets db:migrate
```

## Confirm with Web GUI

Found [dynamodb-admin](), GUI for DynamoDB Local or dynalite, the one that works.  They other ones I tried were broken.  One thing you might run into is that dynamodb-local uses AWS_ACCESS_KEY_ID to namespace the local database that gets created.  dynamodb-admin sets this to ['key'](https://github.com/aaronshaf/dynamodb-admin/blob/master/index.js#L32) by default.  So if you do have your AWS_ACCESS_KEY_ID set and are using AWS_PROFILE like I'm doing, then the local dynamodb database won't match with dynamodb-admin and your other tools.  TLDR; set AWS_ACCESS_KEY_ID.

```sh
dynamodb-admin
```

Once dynamodb-admin is running, you can use [http://localhost:8001/](http://localhost:8001/) as a GUI to quickly navigate through the tables.
