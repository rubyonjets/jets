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

<a id="prev" class="btn btn-basic" href="{% link _docs/email-configuration-mailgun.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/custom-resources.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
