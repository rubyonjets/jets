class Lam::Process::Help
  class << self
    def controller
<<-EOL
Examples:

lam process controller '{ "we" : "love", "using" : "Lambda" }' '{"test": "1"}' "handlers/controllers/posts.create"
EOL
    end
  end
end
