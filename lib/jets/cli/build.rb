class Jets::CLI
  class Build < Base
    def run
      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Remote::Runner.new(@options.merge(command: "build")).run
    end
  end
end
