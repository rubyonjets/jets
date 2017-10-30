class Jets::Process::Help
  class << self
    def controller
<<-EOL
Processes node shim controller handler. This is the command that the node shim spawns out to.

Example:

$ jets process controller '{"we":"love","using":"Lambda"}' '{"test": "1"}' "handlers/controllers/posts.create"
EOL
    end

    def job
<<-EOL
Processes node shim job handler. This is the command that the node shim spawns out to.

Example:

$ jets process job '{"we":"love","using":"Lambda"}' '{"test": "1"}' "handlers/job/sleep.perform"
EOL
    end
  end
end
