class Jets::CLI
  module AutoscalingConcern
    extend Memoist
    include Jets::AwsServices::AwsHelpers

    def autoscaling_enabled?
      false
      # describe cfn to see if autoscaling is enabled
      # config.ecs.autoscaling.enabled &&
      #   config.ecs.autoscaling.min_capacity &&
      #   config.ecs.autoscaling.max_capacity
    end

    # TODO: move to release and use api to reduce AWS calls and make faster
    def service
      parent_stack = find_stack(Jets.project.namespace)
      return unless parent_stack
      output = parent_stack.outputs.find do |o|
        o.output_key == "Ecs"
      end
      return unless output

      ecs_stack_resources = cfn.describe_stack_resources(stack_name: output.output_value).stack_resources
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
