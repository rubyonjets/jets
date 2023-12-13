module Jets::CLI::Lambda
  class Lookup
    class Error < StandardError
      class ParentStack < self; end

      class Output < self; end

      class ChildStack < self; end
    end

    class << self
      def function(name)
        new(name).lookup
      end
    end

    include Jets::AwsServices
    def initialize(name)
      @name = name
    end

    MAX_FUNCTION_NAME_SIZE = 64
    def function_name
      name = if @name.starts_with?(Jets.project.namespace)
        @name # fully qualified function name
      elsif !ENV["JETS_RESET"]
        [Jets.project.namespace, @name].join("-")
      else
        lookup
      end
      (name.size > MAX_FUNCTION_NAME_SIZE) ? lookup : name
    end

    def lookup
      if @name == "controller"
        class_name, meth = "Controller", ""
      else
        # IE: jets-prewarm_event-handle
        #     class_name => "JetsPrewarm" - no colons ::
        #     meth => "Handle"
        parts = @name.split("-")
        meth = parts.pop.tr("-", "_").camelize
        class_name = parts.join("_").camelize
      end

      parent_name = Jets::Names.parent_stack_name
      parent = cfn.describe_stacks(stack_name: parent_name).stacks.first
      unless parent
        raise Error::ParentStack, "Unable to find parent stack #{parent_name}"
      end

      # Can occur while stack is initially creating for the first time
      output = parent.outputs.find { |o| o.output_key == class_name }
      unless output
        raise Error::Output, "Unable to find output #{class_name} in parent stack #{parent_name}"
      end

      # Can occur while stack is initially creating for the first time
      child_name = output.output_value
      child = cfn.describe_stacks(stack_name: child_name).stacks.first
      unless child
        raise Error::ChildStack, "Unable to find child stack #{parent_name}"
      end
      output = child.outputs.find { |o| o.output_key == "#{meth}LambdaFunction" }
      output.output_value
    end
  end
end
