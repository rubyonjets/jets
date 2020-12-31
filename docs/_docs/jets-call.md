---
title: Jets Call
---

## Remote Lambda Function

You can use `jets call` to test with the CLI. Example:

    $ jets call posts-controller-index '{"test":1}' | jq '.body | fromjson'
    {
      "hello": "world",
      "action": "index"
    }
    $ jets call help # for more info like passing the payload via a file
                     # or how to call the functions locally with --local

The corresponding `aws lambda` CLI commands would be:

    aws lambda invoke --function-name demo-dev-posts_controller-index --payload '{"queryStringParameters":{"test":1}}' outfile.txt
    cat outfile.txt | jq '.body | fromjson'
    rm outfile.txt
    aws lambda invoke help

For controllers, the `jets call` method wraps the parameters in the lambda [proxy integration input format structure](http://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format) for your convenience.

## Local Function

The `jets call` command supports a local testing mode with the `--local` option.  This allows you to test locally before deploying.  Here's an example:

    jets call posts-controller-index '{"test":1}' --local

For more info and `jets call` examples, check out the CLI reference: [jets call cli](http://rubyonjets.com/reference/jets-call/).

