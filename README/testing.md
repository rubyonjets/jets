# Testing

## Unit

To run unit tests:

    bundle exec rspec

## Integration

To run the integration tests locally, you need to create a new Jets CRUD project and start the server:

    jets new demo
    cd demo
    jets generate scaffold Post title:string
    jets server

Then you can run the postman tests:

    spec/bin/integration.sh

The integration.sh script ensures that the necessary data exists for the postman integration test to pass.  It ultimately calls:

    newman run spec/fixtures/postman/collection.json -e spec/fixtures/postman/environment.json

The integration test results should look something like this:

* [Jets Integration Test Results](https://gist.github.com/tongueroo/fcea2b2f48342d1448d3f258fcd6536c)