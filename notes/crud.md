# Jets CRUD with CURL Demo

Note, I'm using [jq](https://stedolan.github.io/jq/) to pretty print the json responses.

posts#index

```sh
curl -s http://localhost:8888/posts | jq .
```

posts#new

```sh
curl -s http://localhost:8888/posts/new | jq .
```

posts#create

```sh
curl -s -X POST http://localhost:8888/posts -d '{
  "Key1": "Value1",
  "Key2": "Value2"
}' | jq .
```
