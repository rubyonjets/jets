---
title: Env Extra
---

Jets has the concept of extra environments. This can be controlled by the `JETS_ENV_EXTRA` variable.  By setting `JETS_ENV_EXTRA` you can create additional identical environments.

    jets deploy # first environment demo-dev
    JETS_ENV_EXTRA=2 jets deploy # creates a demo-dev-2 environment

The `JETS_ENV_EXTRA` can also be set in the `config/application.rb` file:

```ruby
Jets.application.configure do
  # ...
  config.env_extra = 2 # can also set this with JETS_ENV_EXTRA
end
```

Interestingly, since AWS Lambda pricing is based on usage. These extra environments cost you pretty much nothing. They're literally free until you exceed the [free tier](https://aws.amazon.com/free/).  Create 10 extra Development, Staging or UAT environments if you need them 🎉

## Precedence

1. JETS_ENV_EXTRA - takes the highest precedence
2. `config/application.rb` env_extra setting - takes lower precedence

## Blue-Green Deployments

With the ability to create entire applications with just a variable change, you can use it to perform blue-green deployments.

1. Create another environment
2. Test it to your heart's content
3. Switch the DNS over to the new stack
4. Delete the old environment

