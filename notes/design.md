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