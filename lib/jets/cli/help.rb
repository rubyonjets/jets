module Jets
  class CLI < Command
    class Help
      class << self
        def build
<<-EOL
Builds and prepares project for AWS Lambda.  Generates a node shim and bundles Traveling Ruby in the bundled folder.  Creates a zip file to be uploaded to Lambda for each handler. This allows you to build the project and inspect the zip file that gets deployed to AWS Lambda.
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

      end
    end
  end
end
