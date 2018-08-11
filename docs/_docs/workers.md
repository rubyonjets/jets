---
title: Workers
---

A Jets worker handles background jobs. It is performed outside of the web request/response cycle. Here's an example:

```ruby
class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    {done: "digging"}
  end

  cron "0 */12 * * ? *" # every 12 hours
  def lift
    {done: "lifting"}
  end
end
```

`HardJob#dig` will be ran every 10 hours and `HardJob#lift` will be ran every 12 hours.

<a id="prev" class="btn btn-basic" href="{% link _docs/routing.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/install.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
