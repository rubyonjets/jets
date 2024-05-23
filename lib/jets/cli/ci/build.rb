class Jets::CLI::Ci
  class Build < Base
    def run
      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Remote::Runner.new(@options.merge(command: "ci:build")).run
    end
  end
end
