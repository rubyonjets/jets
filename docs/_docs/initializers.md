---
title: Initializers
---

Jets supports custom initalization by running your app's `config/initalizers` files during the bootup process.  Here's an example:

config/initializers/custom.rb:

```ruby
Jets.application.config.silly = ActiveSupport::OrderedOptions.new
Jets.application.config.silly.name = "FooBar"
```

The example above is just a simple example.

<a id="prev" class="btn btn-basic" href="{% link _docs/jets-turbines.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/custom-resources.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
