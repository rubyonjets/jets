module Jets::Cfn
  class Stack
    extend Memoist
    include Jets::AwsServices
    include Jets::Util::Logging
    include Rollback    # delete_rollback_complete!
    include Deployable  # check_deployable!

    def initialize(options)
      @options = options
    end

    def stack_name
      Jets.project.namespace
    end

    def check_stack_exist!
      stack = find_stack(stack_name)
      return if stack
      puts "ERROR: Stack #{stack_name} does not exist".color(:red)
      exit 1
    end
  end
end
