The node shim spawns out to this command.

## Example

    $ jets process:controller '{"pathParameters":{}}' '{"context":"data"}' "handlers/controllers/posts_controller.index"
    $ jets process:controller '{"pathParameters":{"id":"tung"}}' '{}' handlers/controllers/posts_controller.show
