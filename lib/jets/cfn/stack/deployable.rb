class Jets::Cfn::Stack
  module Deployable
    # All CloudFormation states listed here: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    def check_deployable!
      return if !stack_exists?(stack_name)

      resp = cfn.describe_stacks(stack_name: stack_name)
      status = resp.stacks[0].stack_status
      if /_IN_PROGRESS$/.match?(status)
        log.error "ERROR: The '#{stack_name}' stack status is #{status}".color(:red)
        log.error "Please wait until the stack is ready and try again."
        exit 1
      end
    end
  end
end
