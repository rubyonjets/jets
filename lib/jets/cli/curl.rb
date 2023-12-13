class Jets::CLI
  class Curl < Base
    def run
      result = Request.new(options).run
      # only thing that goes to stdout. so can pipe to commands like jq
      puts JSON.pretty_generate(result)
    end
  end
end
