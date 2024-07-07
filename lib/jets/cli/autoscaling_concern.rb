class Jets::CLI
  module AutoscalingConcern
    extend Memoist
    include Jets::AwsServices::AwsHelpers

    # TODO: move to release and use api to reduce AWS calls and make faster
    def autoscaling_enabled?
      return unless ecs_stack_name
      ecs_stack_resources.detect do |r|
        r.resource_type == "AWS::ApplicationAutoScaling::ScalableTarget"
      end
    end

    def ecs_stack_resources
      return [] unless ecs_stack_name
      cfn.describe_stack_resources(stack_name: ecs_stack_name).stack_resources
    end
    memoize :ecs_stack_resources

    def ecs_stack_name
      parent_stack = find_stack(Jets.project.namespace)
      return unless parent_stack
      output = parent_stack.outputs.find do |o|
        o.output_key == "Ecs"
      end
      output&.output_value
    end
    memoize :ecs_stack_name

    # TODO: move to release and use api to reduce AWS calls and make faster
    def service
      return unless ecs_stack_name
      resource = ecs_stack_resources.find do |r|
        r.resource_type == "AWS::ECS::Service"
      end
      service = resource.physical_resource_id.split("/").last

      resource = ecs_stack_resources.find do |r|
        r.resource_type == "AWS::ECS::Cluster"
      end
      @cluster = resource.physical_resource_id.split("/").last

      services = ecs.describe_services(
        cluster: @cluster,
        services: [service]
      ).services
      @service = services.first
    end
    memoize :service
  end
end
