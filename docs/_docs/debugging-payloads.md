---
title: Debugging Event Payloads
---

Here are examples of event payloads for a typical CRUD controller.

Action | Payload | Notes
--- | --- | ---
posts#index | `{"path": "/posts"}` | Path is always required.
posts#new | `{"path": "/posts/new"}` | The new action uses the path to generate the new form.
posts#show | `{"path": "/posts/123"}` | The post id must be provided and exist in the database or you'll get a "Couldn't find Post without an ID" error.  123 is an example.
posts#edit | `{"path": "/posts/123/edit", "pathParameters": {"id": "123"}}` | You will also need pathParameters because that's how the controller gets the id parameter.

<a id="prev" class="btn btn-basic" href="{% link _docs/debugging-cloudformation.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/jets-turbines.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
