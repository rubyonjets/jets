## Remote mode

Invoke the lambda function on AWS.

## Examples Cheatsheet

    jets call -n cool_event-party -e '{"test":1}'
    jets call -n cool_event-party -e '{"test":1}' | jq .
    jets call -n cool_event-party -e '{"test":1}' --verbose | jq
    jets call -n cool_event-party file://event.json | jq . # load event with a file
    jets call -n jets-prewarm_event-handle -e '{"invocation_type": "RequestResponse"}'

The equivalent AWS Lambda CLI command:

    aws lambda invoke --function-name demo-dev-cool_event-party --payload -e '{"test":1}' outfile.txt
    cat outfile.txt | jq '.'

## Logs

The `jets call` command can also print out the last 4KB of the lambda logs with the `--verbose` option. The logging output is directed to stderr and the response output from the lambda function itself is directed to stdout so you can safely pipe the results of the call command to other tools like `jq`.

## Controller Note

You can directly call a controller but you must provide it with a event payload that it understands. IE: The event payload needs to come from Lambda Fucntion URL, APIGW, or ALB.

    jets call -n controller --event file://lambda.json

The `jets curl` handles this more automatically is recommended over the `jets call` command for calling Jets controller.
