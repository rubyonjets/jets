---
title: Controller Spec
---

Here's a simple example of a controller spec.

spec/controllers/post_controller_spec.rb:

```ruby
describe PostsController, type: :controller do
  it "index returns a success response" do
    get '/posts'
    expect(response.status).to eq 200
  end
end
```

The controller spec helpers provide the http verb methods: `get`, `post`, `put`, `patch`, `delete`. You can pass `headers`, `params`, `query`, and `body` to the the methods also. Example:

```ruby
describe PostsController, type: :controller do
  it "index returns a success response" do
    get '/posts', headers: {"MyHeader": "foo"}
    expect(response.status).to eq 200
  end
end
```

You can override what is passed as a body by using the `body` param along with `Content-Type` header. This works for non-GET requests only.

```ruby
describe PostsController, type: :controller do
  it "index returns a success response" do
    article = JSON.generate(title: "Hello", content: "World!")
    post '/posts', body: article, headers: {"Content-Type": "application/json"}
    expect(response.status).to eq 201
  end
end
```

The response will have the `status`, `headers`, and `body` set after an test http request has been called.  Example:

```ruby
describe PostsController, type: :controller do
  it "index returns a success response" do
    get '/posts'
    expect(response.status).to eq 200
    pp response.headers
    pp response.body
  end
end
```

When you run specs, you may need to migrate first. Here are the commands:

    JETS_ENV=test jets db:create db:migrate
    bundle exec rspec

