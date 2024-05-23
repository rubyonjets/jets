class Jets::CLI::Ci
  class Delete < Base
    def run
      are_you_sure?
      check_exist!
      Jets::Cfn::Bootstrap.new(@options).run
      Jets::Remote::Runner.new(@options.merge(command: "ci:delete")).run
    end

    private

    def are_you_sure?
      unless @options[:yes]
        sure?("Will delete #{stack_name.color(:green)}")
      end
    end

    def check_exist!
      unless stack_exists?(stack_name)
        puts "Stack does not exist: #{stack_name.color(:green)}"
        exit 1
      end
    end
  end
end
