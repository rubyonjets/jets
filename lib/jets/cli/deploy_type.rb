class Jets::CLI
  module DeployType
    extend Memoist
    include Jets::AwsServices::AwsHelpers

    def deploy_type
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
    memoize :deploy_type
  end
end
