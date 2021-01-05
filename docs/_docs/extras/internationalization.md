---
title: Jets Internationalization (I18n)
---

This guide shows you how to set up simple internationalization with Jets.

## Summary of Files

Here's a summary of the files we'll update:

    app/controllers/application_controller.rb
    app/views/posts/index.html.erb
    config/initializers/i18n.rb
    config/locales/en.yml

## Setup Initializer and Locale YAML

Set I18n library so it knows which YAML files to load the locale translations.

config/initializers/i18n.rb

```ruby
I18n.load_path = Dir["#{Jets.root}/config/locales/*.yml"]
I18n.backend.load_translations
```

config/locales/en.yml

```yaml
en:
  hello: "Hello world"

ru:
  hello: "Добро пожаловать!"
```

## Setup Controller Action Filter

Set up a `before_action` filter so that locale is controlled with a `locale` parameter. IE: `locale=en`

app/controllers/application_controller.rb

```ruby
class ApplicationController < Jets::Controller::Base
  before_action :set_locale

private
  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end
  def extract_locale
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end
end
```

## Update View

Add test ERB that calls the `t` method which is i18n aware.

app/views/posts/index.html.erb

```erb
<p>Test i18n: <%= t 'hello' %></p>
```

Visiting http://localhost:8888/posts?locale=en you'll see something like this:

    Test i18n: Hello world

And visiting http://localhost:8888/posts?locale=ru you'll get:

    Test i18n: Добро пожаловать!

