# Testing

## Unit

To run unit tests:

    bundle exec rspec

## Integration

To run the integration tests locally, you need to create a new Jets CRUD project:

    jets new demo
    cd demo
    jets generate scaffold Post title:string

Create a data record that the postman tests assumes:

    $ jets console
    > Post.create(id: 2) unless Post.find_by(id: 2)

Start the server:

    jets server

Then you can run the postman tests:

    newman run spec/fixtures/postman/collection.json -e spec/fixtures/postman/environment.json

The integration test results should look something like this:

* [Jets Integration Test Results](https://gist.github.com/tongueroo/fcea2b2f48342d1448d3f258fcd6536c)