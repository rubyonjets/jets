class Jets::CLI::Package
  class Dockerfile < Jets::CLI::Base
    def run
      sure?("Will build a Dockerfile for #{Jets.project.namespace.color(:green)}")
      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Remote::Runner.new(@options.merge(command: "package:dockerfile")).run
    end
  end
end
