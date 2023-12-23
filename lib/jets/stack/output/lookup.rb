class Jets::Stack::Output
  class Lookup
    include Jets::AwsServices

    def initialize(stack_subclass)
      @stack_subclass = stack_subclass
    end

    @@cache = {}
    def output(logical_id)
      cache_key = "#{@stack_subclass}-#{logical_id}"
      return @@cache[cache_key] if @@cache[cache_key]

      child_stack_id = @stack_subclass.to_s.camelize

      stack_arn = shared_stack_arn(child_stack_id)
      resp = cfn.describe_stacks(stack_name: stack_arn)
      child = resp.stacks.first
      return unless child

      @@cache[cache_key] = output_value(child, logical_id)
    end

    # Shared child stack arn
    def shared_stack_arn(logical_id)
      parent_stack = Jets.project_namespace
      resp = cfn.describe_stacks(stack_name: parent_stack)
      parent = resp.stacks.first
      output_value(parent, logical_id)
    end

    def output_value(stack, key)
      key = key.to_s.camelize
      output = stack.outputs.find do |o|
        o.output_key == key
      end
      output&.output_value
    end
  end
end