class Jets::Stack::Output
  class Lookup
    include Jets::AwsServices

    def output(logical_id)
      resp = cfn.describe_stacks(stack_name: shared_stack_arn)
      child = resp.stacks.first
      return unless child

      logical_id = logical_id.to_s.camelize
      output_value(child, logical_id)
    end

    # Shared child stack arn
    def shared_stack_arn
      resp = cfn.describe_stacks(stack_name: stack_name)
      parent = resp.stacks.first
      output_value(parent, shared_logical_id_base)
    end

    def output_value(stack, key)
      output = stack.outputs.find do |o|
        o.output_key == key
      end
      output&.output_value
    end

    def stack_name
      Jets.config.project_namespace
    end
  end
end