---
title: Directory Structure
---

A basic lono project usually looks something like this:

```sh
├── app
│   ├── definitions
│   │   │── base.rb
│   │   │── development.rb
│   │   └── production.rb
│   ├── helpers
│   ├── partials
│   ├── scripts
│   ├── templates
│   │   └── ec2.yml
│   └── user_data
├── config
│   ├── params
│   │   ├── base
│   │   │   └── ec2.txt
│   │   └── production
│   │       └── ec2.txt
│   │── variables
│   │   ├── base.rb
│   │   └── production.rb
│   └── settings.yml
└── output
```

{% include structure.md %}

That should give you a basic feel for the lono directory structure.

<a id="prev" class="btn btn-basic" href="{% link _docs/components.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/lono-env.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
