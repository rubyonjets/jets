---
title: Events
---

Jets is also a powerful Glue Serverless Framework.

AWS Lambda supports many event triggers.  With event triggers, you can use Lambda functions as glue. Here's a list of the events supported by Jets.

<ul>
{% assign event_docs = site.docs | where: "categories","events" %}
{% for doc in event_docs %}
  <li><a href='{{doc.url}}'>{{doc.title}}</a></li>
{% endfor %}
</ul>

The next sections cover the event triggers.

