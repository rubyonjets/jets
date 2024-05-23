class Jets::CLI::Waf
  class Build < Base
    def run
      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Remote::Runner.new(@options.merge(command: "waf:build")).run
    end
  end
end
