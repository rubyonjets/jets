class Jets::CLI::Waf
  class Deploy < Base
    def run
      are_you_sure?
      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Remote::Runner.new(@options.merge(command: "waf:deploy")).run
    end

    def are_you_sure?
      sure? <<~EOL
        Will deploy stack #{stack_name.color(:green)} to us-east-1

        Uses #{Jets.project.namespace} remote runner to deploy a separate stack for WAF resources.
      EOL
    end
  end
end
