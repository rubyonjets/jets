---
title: Email Configuration Mailgun
---

Here's an example on how to set up email with Mailgun.

Gemfile:

```ruby
gem 'mailgun-ruby'
```

config/environments/production.rb:

```ruby
require 'railgun/mailer'
require 'railgun/message'

Jets.application.configure do
  config.action_mailer.show_previews = false # default: false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.add_delivery_method :mailgun, Railgun::Mailer
  config.action_mailer.delivery_method = :mailgun
  config.action_mailer.mailgun_settings = {
    api_key: ENV['MAILGUN_API_KEY'],
    domain: ENV['MAILGUN_DOMAIN'],
  }
end
```

.env.production:

```sh
MAILGUN_API_KEY=ADJ23JOXELX
MAILGUN_DOMAIN=mydomain.com
```

