---
title: Local Server
---

To speed up development, you can run a local server which mimics API Gateway. Test your application code locally and then deploy to AWS when ready.

```
jets server
```

You can test your app at http://localhost:8888. Here's a curl command to create a post:

```
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

You can find examples of all the CRUD actions at [Jets CRUD Tutorials]({% link _docs/crud-tutorials.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/structure.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/repl-console.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
