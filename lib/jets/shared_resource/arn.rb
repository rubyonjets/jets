class Jets::SharedResource
  module Arn
    include Jets::AwsServices

    def arn(logical_id)
      resp = cfn.describe_stacks(stack_name: shared_stack_arn)
      child = resp.stacks.first
      return unless child

      logical_id = full_logical_id(logical_id)
      output(child, logical_id)
    end

    # Shared child stack arn
    def shared_stack_arn
      resp = cfn.describe_stacks(stack_name: stack_name)
      parent = resp.stacks.first
      output(parent, shared_logical_id_base)
    end

    def output(stack, key)
      output = stack.outputs.find do |o|
        o.output_key == key
      end
      output&.output_value
    end

    def stack_name
      Jets.config.project_namespace
    end

    def full_logical_id(logical_id)
      return logical_id if logical_id =~ /^shared/ # already provided full logical id

      "#{shared_logical_id_base}_#{logical_id}".camelize
    end

    def shared_logical_id_base
      class_name = self.to_s
      "shared_#{class_name.underscore}".camelize
    end
  end
end