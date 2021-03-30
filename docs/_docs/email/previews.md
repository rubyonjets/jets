---
title: Email Previews
---

Jets supports previewing emails from [localhost:8888/jets/mailers](localhost:8888/jets/mailers). This can be enabled with:

config/environments/development.rb:

```ruby
Jets.application.configure do
  config.action_mailer.show_previews = true # default: false
end
```

## Previewing Emails

Here's an example showing how to use email previews.

    jets new demo
    cd demo
    jets generate migration create_users name:string
    jets db:migrate
    jets generate mailer UserMailer new_user

Then create a preview model with a naming convention in the `app/previews` folder like so.

app/previews/user_mailer_preview.rb:

```ruby
class UserMailerPreview < ActionMailer::Preview
  def new_user
    UserMailer.new_user
  end
end
```

To see the email preview visit: [localhost:8888/jets/mailers/user_mailer/new_user](localhost:8888/jets/mailers/user_mailer/new_user).  You should see something like this:

![](/img/docs/email-preview.png)

