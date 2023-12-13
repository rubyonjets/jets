class Jets::CLI::Waf
  class Delete < Base
    def run
      are_you_sure?
      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Remote::Runner.new(@options.merge(command: "waf:delete")).run
    end

    private

    def are_you_sure?
      unless @options[:yes]
        sure?("Will delete #{stack_name.color(:green)} in us-east-1")
      end
    end
  end
end
