The `jets curl` command mimics the curl interface and directly invokes the AWS Lambda function. It is helpful in debugging the underlying Lambda event and response structure.

Key points:

* The `jets curl` command calls the AWS Lambda function with the `invoke` API call.
* It translates the curl-like options into a Lambda Function URL event payload.
* The event is sent to your Jets controller Lambda function.
* The **raw** Lambda Function response is sent back.
* You can pipe this to `jq` for pretty output.

Example:

    ❯ jets curl / | jq
    Calling Lambda function event-app-dev-controller
    Response:
    {
    "statusCode": 200,
    "headers": {
        "Content-Type": "text/plain"
    },
    "body": "Hello, World!",
    "cookies": [
        "my_cookie=my_value; Path=/"
    ],
    "isBase64Encoded": false
    }

Only a path is needed. IE: When you don't need to specify a hostname, Jets mimics with a dummy one, IE: dummy.lambda-url.us-west-2.on.aws. If you specify the hostname, `jets curl` will use that value instead of a dummy url.

The `jets curl` command provides some of the curl interfaces but does not cover all curl options exhaustively.

## Examples Cheatsheet

    jets curl / | jq
    jets curl /posts | jq
    jets curl / --cookie cookies.txt | jq
    jets curl / --cookie "cookie1=value1; cookie2=value2"
    jets curl / --cookie-jar cookies.txt | jq
    jets curl / -H Host:example.com
    jets curl / -X POST -d "foo=bar"
    jets curl foobar.lambda-url.us-west-2.on.aws/
    jets curl / --verbose | jq
    jets curl / --verbose --trim | jq

## Multiple Headers

The Thor CLI parses multiple options differently than curl does. Here's how you pass multiple headers.

    jets curl / -H User-Agent:james-bond Host:example.com

## Trim Option

The `--trim` options "trims" values from the Lambda Response Hash to shortened the output so that it's more human-readable. The default trim max length is 64. You can adjust it with the `JETS_CURL_TRIM_MAX` env var.

    export JETS_CURL_TRIM_MAX=32
    jets curl / | jq

## Cookies

You can pass it request cookies with `--cookie` or `-b`.

The `--cookie` option takes a string with values like so:

    jets curl / --cookie "cookie1=value1; cookie2=value2"

To write the response cookies to a file, use the `--cookie-jar` or `-c` option. Example:

    jets curl / --verbose --trim -c cookies.txt

Creates:

cookies.txt

    # HTTP Cookie File
    dummy.lambda-url.us-west-2.on.aws    FALSE   /       FALSE   0       yummy1    value1
    dummy.lambda-url.us-west-2.on.aws    FALSE   /       FALSE   0       yummy2    value2

You can also see the response cookies in the Lambda response hash structure.

Saving the cookies.txt is useful to send it later.

    jets curl / -b cookies.txt