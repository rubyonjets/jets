module Jets
  class CLI < Command
    class Help
      class << self
        def build
<<-EOL
Builds and prepares project for AWS Lambda.  Generates a node shim and vendors Traveling Ruby.  Creates a zip file to be uploaded to Lambda for each handler. This allows you to build the project and inspect the zip file that gets deployed to AWS Lambda.
EOL
        end

        def deploy
<<-EOL
Deploys project to AWS Lambda.  Automatically builds the project as the first step. This creates and or updates a CloudFormation stack.
EOL
        end
      end
    end
  end
end
