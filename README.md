# Lam

[![Build Status](https://magnum.travis-ci.com/)](https://magnum.travis-ci.com/)
[![Code Climate](https://codeclimate.com/)](https://codeclimate.com/)
[![Code Climate](https://codeclimate.com/)](https://codeclimate.com/)

To these the lam, run these commands:

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```sh
gem "lam"
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```
$ gem install lam
```

## Project Structure

TODO: make this a table

```sh
app/controllers
app/workers
app/functions
config/project.yml
config/events.yml
config/routes.rb
```


## Usage

```sh
lam build
lam deploy
```

## Testing

Testing controller processing without node shim.

```
lam process controller '{ "we" : "love", "using" : "Lambda" }' '{"test": "1"}' "handlers/controllers/posts.create"
```

Testing the generated node shim handler and the controller processing.

```
cd spec/fixtures/project
lam build # generates the handlers
node handlers/controllers/posts.js
```

VS

```sh
processors/controller_processor.rb '{ "we" : "love", "using" : "Lambda" }' '{"test": "1"}' "handlers/controllers/posts.create" | jq '.'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
