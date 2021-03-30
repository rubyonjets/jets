---
title: Local Server
---

To speed up development, you can run a local server which mimics API Gateway. Test your application code locally and then deploy to AWS when ready.

    jets server

You can test your app at [http://localhost:8888](http://localhost:8888). Here's a curl command to create a post:

    curl -X POST http://localhost:8888/posts \
      -H 'Content-Type: application/json' \
      -d '{
      "post": {
        "title": "My Test Post 1",
        "desc": "test desc",
      }
    }
    '

You can find examples of all the CRUD actions at [Jets CRUD Tutorials]({% link _docs/tutorials.md %}).

