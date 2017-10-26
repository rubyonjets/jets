module Jets
  class CLI < Command
    class Help
      class << self
        def build
<<-EOL
Builds and prepares project for AWS Jetsbda.  Generates a node shim and vendors Traveling Ruby.  Creates a zip file to be uploaded to Jetsbda for each handler.
EOL
        end

        def process
<<-EOL
TODO: update process help menu
EOL
        end
      end
    end
  end
end
