class Jets::CLI::Ci
  class Deploy < Base
    def run
      are_you_sure?
      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Remote::Runner.new(@options.merge(command: "ci:deploy")).run
    end

    def are_you_sure?
      sure? <<~EOL
        Will deploy stack #{stack_name.color(:green)}

        Uses remote runner to deploy a separate stack for CI resources.
      EOL
    end
  end
end
