# Jets CRUD Curl Demo

Here's a quick CRUD demo with curl.  Note, I'm using [jq](https://stedolan.github.io/jq/) to pretty print the json responses.

posts#index

```sh
$ curl -s http://localhost:8888/posts | jq .
{
  "action": "index",
  "posts": [
    {
      "created_at": "2017-11-04T01:46:03Z",
      "id": "myid",
      "title": "test title",
      "updated_at": "2017-11-04T01:46:03Z",
      "desc": "test desc"
    }
  ]
}
```

posts#new

```sh
$ curl -s http://localhost:8888/posts/new | jq .
{
  "action": "new"
}
```

posts#create

```sh
$ curl -s -X POST http://localhost:8888/posts -d '{
  "id": "myid",
  "title": "test title",
  "desc": "test desc"
}' | jq .
{
  "action": "create",
  "post": {
    "id": "myid",
    "title": "test title",
    "desc": "test desc",
    "created_at": "2017-11-04T01:46:03Z",
    "updated_at": "2017-11-04T01:46:03Z"
  }
}
```

posts#show

```sh
$ curl -s http://localhost:8888/posts/myid | jq .
{
  "action": "show",
  "post": {
    "created_at": "2017-11-04T01:46:03Z",
    "id": "myid",
    "title": "test title",
    "updated_at": "2017-11-04T01:46:03Z",
    "desc": "test desc"
  }
}
```

post#edit

```sh
$ curl -s http://localhost:8888/posts/myid/edit | jq .
{
  "action": "edit",
  "post": {
    "created_at": "2017-11-04T01:46:03Z",
    "id": "myid",
    "title": "test title",
    "updated_at": "2017-11-04T01:46:03Z",
    "desc": "test desc"
  }
}
```

post#update

```sh
$ curl -s -X PUT \
  http://localhost:8888/posts/myid \
  -d '{
  "title": "updated test title",
  "desc": "updated test desc"
}' | jq .
{
  "action": "update",
  "post": {
    "id": "43fe25329f857dc9917160f2e0aac6cdb932c8b8",
    "title": "updated test title",
    "desc": "updated test desc",
    "created_at": "2017-11-04T01:56:22Z",
    "updated_at": "2017-11-04T01:56:22Z"
  }
}
```

post#delete

```sh
$ curl -s -X DELETE http://localhost:8888/posts/myid | jq .
{
  "action": "delete"
}
```
