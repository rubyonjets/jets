---
title: Email Configuration SMTP
---

You can configure email with [initializers]({% link _docs/initializers.md %}).  Example:

config/environments/production.rb:

```ruby
Jets.application.configure do
  config.action_mailer.show_previews = false # default: false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:         ENV['SMTP_ADDRESS'],
    port:            587,
    domain:          ENV['SMTP_DOMAIN'],
    authentication:  :login,
    user_name:       ENV['SMTP_USER_NAME'],
    password:        ENV['SMTP_PASSWORD'],
    enable_starttls_auto: true
  }
end
```

We can configure the variables with [env files]({% link _docs/env-files.md %}).  Example:

.env.production:

```sh
SMTP_ADDRESS=email-smtp.us-west-2.amazonaws.com
SMTP_DOMAIN=mydomain.com
SMTP_USER_NAME=ABCASD5MXAIYXEXAMPLE
SMTP_PASSWORD=ABCunGBKLUdbPdAH/FSxAi8eId99EyAOJz+mxEXAMPLE
```

## Testing SMTP

One way to test SMTP server connection is with telnet. Example:

    $ telnet email-smtp.us-west-2.amazonaws.com 587
    Connected to email-smtp.us-west-2.amazonaws.com.
    Escape character is '^]'.
    telnet> quit
    $

Note, to escape out of the telnet session you have to use the escape sequence `^]`.  That's the control key plus close square bracket key.  Then you can type `quit`.

