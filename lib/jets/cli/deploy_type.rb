class Jets::CLI
  class DeployType < Base
    extend Memoist
    include Jets::AwsServices::AwsHelpers

    delegate :log_group_name,
      to: :strategy

    def strategy
      klass = "Jets::CLI::DeployType::#{deployment_type.to_s.camelize}".constantize
      klass.new(options)
    end

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
    memoize :deployment_type
  end
end
