---
title: Sessions
---

You can use sessions to store data between requests. To use sessions use the `session` helper. Example:

```ruby
class PostsController < ApplicationController
  def index
    session[:current_time] = Time.now
    render json: {message: "set some data in the session"}
  end

  def show
    # session data from previous show request
    puts "session[:current_time] #{session[:current_time]}"
    render json: session
  end
end
```

## Session Storage Backends Configuration

The default cookies session storage can be configured and changed.

### Cookies Storage

Here's an example configuring the default cookie storage backend.

```ruby
Jets.application.configure do
  config.session.options = { key: 'rack.session',
                             domain: 'foo.com',
                             path: '/',
                             expire_after: 2592000,
                             secret: ENV['SECRET_KEY_BASE'],
                             old_secret: ENV['SECRET_KEY_BASE_OLD'] }
end
```

Note, you can also configure the `SECRET_KEY_BASE` with your `.env` files. If you've generated a Jets project after version 1.1.0 then a random `SECRET_KEY_BASE` value was already generated in your `.env`.  You can use [jets secret](/reference/jets-secret/) also to generate a new secret value.

### Memcached Storage

You can use Memcached storage for your sessions. Memcached support is provided with the [dalli](https://github.com/petergoldstein/dalli) and [connection_pool](https://github.com/mperham/connection_pool) gems.  You will need to add them to your Gemfile:

Gemfile:

```ruby
gem "dalli"
gem "connection_pool"
```

You also need to `require "rack/session/dalli"` to add the rack session adapter.  Example:

config/application.rb:

```ruby
require "rack/session/dalli"

Jets.application.configure do
  # ...
  config.session.store = Rack::Session::Dalli
  config.session.options = { memcache_server: "localhost:11211",
                             pool_size: 10 }
end
```

## Sessions Best Practices

It is best practice to store reference data like a database record id in session and look up the record in the application code.  This keeps session data size smaller. Also, the code is more robust to changes when the data structure changes later.  For example, the structure can change when a column is added to the table. The default session storage is cookies.  Cookies are limited to 4k of data.  So keep the session data underneath this limit for cookies.

