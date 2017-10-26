class Jets::Process::Help
  class << self
    def controller
<<-EOL
Examples:

jets process controller '{ "we" : "love", "using" : "Jetsbda" }' '{"test": "1"}' "handlers/controllers/posts.create"
EOL
    end
  end
end
