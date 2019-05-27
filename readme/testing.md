# Testing

## Unit

To run unit tests:

    bundle exec rspec

## Integration

These commands run all from the jets repo itself. The demo folder has been added to the `.gitignore`.

### Locally

To run the integration tests locally, you need to create a new Jets CRUD project and start the server:

    jets new demo
    cd demo
    # edit Gemfile to use the branch of jets being tested
    jets generate scaffold post title:string
    jets import:rails http://github.com/tongueroo/demo-rails.git
    jets server

Then you can run the postman tests:

    spec/integration/local.sh

The integration_local.sh script ensures that the necessary data exists for the postman integration test to pass.  It ultimately calls:

    newman run spec/integration/fixtures/postman/collection.json -e spec/integration/fixtures/postman/environment.json

The integration test results should look something like this:

* [Jets Integration Test Results](https://gist.github.com/tongueroo/fcea2b2f48342d1448d3f258fcd6536c)

### Remotely

Then you can deploy the jets app and test it on real AWS Lambda.

    cp ~/environment/.env.development.remote . # assumes you have a .env.development.remote
    jets deploy

Run the remote integration script:

    eval "export $(cat demo/.env.development.remote)" # for DATABASE_URL for mega mode
    BASE_URL=xxx spec/integration/remote.sh

Manually seed Rails data. Will add this to the remote.sh in the future.

    cd demo/rack
    rails runner 'Book.create(id: 1) unless Book.find_by(id: 1)'

Example:

    eval "export $(cat demo/.env.development.remote)" # for DATABASE_URL for mega mode
    BASE_URL=https://wb5dcjc09a.execute-api.us-west-2.amazonaws.com/dev spec/integration/remote.sh

## Manual Test

Test books create, update and delete manually until it's scripted.
