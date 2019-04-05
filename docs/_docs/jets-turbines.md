---
title: Jets Turbine
---

A `Jets::Turbine` provides hooks to extend Jets and or modify the initialization process.

The interface is currently being developed and will be refined. Here's a table of the currently supported methods:

Method | Description
--- | ---
initalizer | Runs after Jets has been initialized with mainly Jets libraries loaded.
after_initalizer | Runs after Jets has been initialized and has loaded your application specific code.
on_exception | Fires whenever there is an application-wide exception, the registered block of code will be run. This is useful to report errors to error reporting services. Note, this hook only fires on Lambda. Locally, to reproduce you can run code with `Jets.process(event, context, handler)`.  Example: `Jets.process({},{}, "handlers/jobs/hard_job.dig")`.

## Turbine Form

Here's an example of a Turbine taken from the [sentry-jets](https://github.com/tongueroo/sentry-jets/blob/master/lib/sentry_jets/turbine.rb) gem:

```ruby
require 'sentry-raven'

module SentryJets
  class Turbine < ::Jets::Turbine
    initializer 'sentry.configure' do
      Raven.configure do |config|
        config.dsn = ENV['SENTRY_DSN']
      end
    end

    on_exception 'sentry.capture' do |exception|
      Raven.capture_exception(exception)
    end
  end
end
```

<a id="prev" class="btn btn-basic" href="{% link _docs/faster-development.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/initializers.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
