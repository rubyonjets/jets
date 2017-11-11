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
Invoke the lambda function on AWS. Call a few extra things for convenience:

1. Invokes the lambda function on AWS
2. Prints out the Lambda log to stderr.
3. Prints out the response from the lambda funtion to stdout.

Only the response output is directed to stdout so you can safely pipe it into another command.  Other logging output is direct to stderr. This way you can pipe the results of the command to tools like jq.

Examples:

jets call posts-controller-index # event payload is optional

jets call posts-controller-index '{"test":1}'

jets call posts-controller-index '{"test":1}' | jq '.'

jets call posts-controller-show '{"test":1}' --show-log | jq .

The equivalent AWS Lambda CLI command:

aws lambda invoke --function-name demo-dev-posts-controller-index --payload '{"test":1}' outfile.txt

cat outfile.txt | jq '.'

`jets invoke` adds the function namespace making the command shorter.

EOL
        end
      end
    end
  end
end
