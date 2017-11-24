class Jets::Process::Help
  class << self
    def controller
<<-EOL
Processes node shim controller handler. The node shim spawns out to this command.

Example:

$ jets process controller '{"pathParameters":{}}' '{"context":"data"}' "handlers/controllers/posts_controller.index"

$ jets process controller '{"pathParameters":{"id":"tung"}}' '{}' handlers/controllers/posts_controller.show
EOL
    end

    def job
<<-EOL
Processes node shim job handler. The node shim spawns out to this command.

Example:

$ jets process job '{"we":"love", "using":"Lambda"}' '{"context":"data"}' "handlers/jobs/hard_job.dig"
EOL
    end

    def function
<<-EOL
Processes node shim job handler. The node shim spawns out to this command.

Example:

$ jets process function '{"key1":"value1"}' '{}' "handlers/function/hello.world"
EOL
    end
  end
end
