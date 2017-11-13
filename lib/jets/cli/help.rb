module Jets
  class CLI < Command
    class Help
      class << self
        def build
<<-EOL
Builds and prepares project for AWS Lambda.  Generates a node shim and bundles a Linux Ruby in the bundled folder.  Creates a zip file to be uploaded to Lambda for each handler. This allows you to build the project and inspect the zip file that gets deployed to AWS Lambda.
EOL
        end

        def deploy
<<-EOL
Builds and deploys project to AWS Lambda.  This creates and or updates the CloudFormation stack.

$ jets deploy
EOL
        end

        def delete
<<-EOL
Deletes project and all its resources. You can bypass the are you sure prompt with the `--sure` flag.

$ jets delete --sure
EOL
        end

        def new_long_desc
<<-EOL
Creates a new starter jets project.  You can use the `--template` flag to use different templates.  2 supported templates: starter and barebones.  The default is a barebones starter project.

$ jets new proj
EOL
        end

        def server
<<-EOL
Starts a local server for development.  The server mimics API Gateway and provides a way to test your app locally without deploying to AWS.

$ jets server
EOL
        end

        def routes
<<-EOL
Prints your apps routes.

$ jets routes
EOL
        end

        def console
<<-EOL
REPL console with Jets environment loaded.

$ jets console
> Post.find("myid")
EOL
        end

        def call
<<-EOL
Invoke the lambda function on AWS. The `jets call` command can do a few extra things for your convenience:

It adds the function namespace to the function name.  So, you pass in "posts_controller-index" and the Lambda function is "demo-dev-posts_controller-index".

It can print out the last 4KB of the lambda logs. The logging output is directed to stderr.  The response output from the lambda function itself is directed to stdout.  This is done so you can safely pipe the results of the call command to other tools like jq.

For controllers, the event you pass at the CLI is automatically transformed into Lambda Proxy payload that contains the params as the queryStringParameters.  For example:

{"test":1}

Gets changed to:

{"queryStringParameters":{"test":1}}

This spares you from assembling the event payload manually to the payload that Jets controllers normally recieve.  If you would like to disable this Lambda Proxy transformation then use the `--no-lambda-proxy` flag.

For jobs, the event is passed through untouched.

Examples:

jets call hard_job-drive '{"test":1}'

jets call hard_job-drive '{"test":1}' | jq .

jets call hard_job-drive file://event.json | jq . # load event with a file

jets call posts_controller-index # event payload is optional

jets call posts_controller-index '{"test":1}' --show-log | jq .

jets call posts_controller-index 'file://event.json' --show-log | jq .

The equivalent AWS Lambda CLI command:

aws lambda invoke --function-name demo-dev-hard_job-dig --payload '{"test":1}' outfile.txt ; cat outfile.txt | jq '.'

aws lambda invoke --function-name demo-dev-posts_controller-index --payload '{"queryStringParameters":{"test":1}}' outfile.txt ; cat outfile.txt | jq '.'

For convenience, you can also provide the function name with only dashes and jets call figures out what function you intend to call. Example:

jets call admin-related-pages-controller-index

Gets turned into:

aws lambda invoke --function-name demo-dev-admin/related_pages_controller-index

EOL
        end
      end
    end
  end
end
