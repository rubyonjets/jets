module Jets::AwsServices
  module AwsHelpers # :nodoc:
    include Jets::AwsServices

    def deployment_type
      parent_stack = find_stack(parent_stack_name)
      return unless parent_stack
      parent_stack.outputs.find do |o|
        case o.output_key
        when "Ecs"
          return "ecs"
        when "Controller"
          return "lambda"
        end
      end
    end

    def parent_stack_name
      Jets.project.namespace
    end

    def find_stack(stack_name)
      resp = cfn.describe_stacks(stack_name: stack_name)
      resp.stacks.first
    rescue Aws::CloudFormation::Errors::ValidationError => e
      # example: Stack with id demo-dev does not exist
      if e.message =~ /Stack with/ && e.message =~ /does not exist/
        nil
      else
        raise
      end
    end
  end
end
