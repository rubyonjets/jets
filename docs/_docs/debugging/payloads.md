---
title: Debugging Event Payloads
---

Here are examples of event payloads for a typical CRUD controller.  You must always specify the `path` key.

Action | Payload | Notes
--- | --- | ---
posts#index | `{"path": "/posts"}` | Path is always required.
posts#new | `{"path": "/posts/new"}` | The new action uses the path to generate the new form.
posts#show | `{"path": "/posts/123"}` | The post id must be provided and exist in the database or you'll get a "Couldn't find Post without an ID" error.  123 is an example.
posts#edit | `{"path": "/posts/123/edit", "pathParameters": {"id": "123"}}` | You will also need pathParameters because that's how the controller gets the id parameter.

