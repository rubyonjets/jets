---
title: Ruby Versions Support
---

Jets supports Ruby 2.5 and Ruby 2.7. Patch variants of it should work.

## Using Different Ruby Versions

Generally, Jets detects the current version of ruby that is installed on your system and will use that one. If you want to use ruby 2.7, switch to it and deploy with it.

It is recommend that you use rbenv or rvm to switch to the targeted ruby version and deploy.  Here's an example with rbenv.

    rbenv local 2.7.2
    jets deploy

Here's another example with rvm.

    rvm use 2.5.8
    jets deploy

## Bypass Ruby Version Check

Jets checks your current ruby version and makes sure its a version that Jets supports. If you would like to bypass this check, you can set `JETS_RUBY_CHECK=0`. You can can also set a config.

config/appplication.rb

```ruby
Jets.application.configure do
  config.ruby.check = false
end
```
