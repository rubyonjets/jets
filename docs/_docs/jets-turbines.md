---
title: Jets Turbine
---

A `Jets::Turbine` provides hooks to extend Jets and or modify the initialization process. This is useful if you want to develop a third party extension for Jets like [sentry-jets](https://github.com/tongueroo/sentry-jets).

The interface is currently being developed and will be refined. Here's a table of the currently supported methods:

Method | Description
--- | ---
initalizer | Runs after Jets has been initialized with mainly Jets libraries loaded.
after_initalizer | Runs after Jets has been initialized and has loaded your application-specific code.
on_exception | Fires whenever there is an application-wide exception, the registered block of code will be run. This is useful to report errors to error reporting services. Note, this hook only fires on Lambda. Locally, to reproduce you can run code with `Jets.process(event, context, handler)`.  Example: `Jets.process({},{}, "handlers/jobs/hard_job.dig")`.

If you don't want to develop a third party extension for Jets, you should use plain old initializer. An initializer is any Ruby file stored under config/initializers in your application.

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

