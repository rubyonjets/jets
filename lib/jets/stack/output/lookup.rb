class Jets::Stack::Output
  class Lookup
    include Jets::AwsServices

    def output(logical_id)
      logical_id = logical_id.to_s.camelize

      stack_arn = shared_stack_arn(logical_id)
      resp = cfn.describe_stacks(stack_name: stack_arn)
      child = resp.stacks.first
      return unless child

      output_value(child, logical_id)
    end

    # Shared child stack arn
    def shared_stack_arn(logical_id)
      parent_stack = Jets.config.project_namespace
      resp = cfn.describe_stacks(stack_name: parent_stack)
      parent = resp.stacks.first
      output_value(parent, logical_id)
    end

    def output_value(stack, key)
      output = stack.outputs.find do |o|
        o.output_key == key
      end
      output&.output_value
    end
  end
end