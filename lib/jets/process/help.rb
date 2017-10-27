class Jets::Process::Help
  class << self
    def controller
<<-EOL
Processes the lamdba function. This is the command that the node shim spawns out to.

Example:

$ jets process controller '{ "we" : "love", "using" : "Lambda" }' '{"test": "1"}' "handlers/controllers/posts.create"
EOL
    end
  end
end
