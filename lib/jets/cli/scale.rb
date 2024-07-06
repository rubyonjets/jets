class Jets::CLI
  class Scale < Jets::CLI::Base
    include Jets::AwsServices::AwsHelpers

    def initialize(options = {})
      super
      @desired = options[:desired]
      @min = options[:min]
      @max = options[:max]
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

    def update
      unless service
        log.error "ERROR: Unable to find ECS service for #{Jets.project.namespace}".color(:red)
        log.error "Are you sure you it's deployed?"
        exit 1
      end

      puts "service #{service.service_name}"

      unless @desired || @min || @max
        log.info <<~EOL
          No --desired --min or --max options provided
          Not taking any actions
        EOL
        return
      end

      log.info "Configuring ECS scaling settings for #{Jets.project.namespace}"
      set_desired_count
      # set_autoscaling
      warning
    end

    def set_desired_count
      return unless @desired
      ecs.update_service(
        service: service.service_name,
        cluster: @cluster,
        desired_count: @desired
      )
      log.info "Configured desired count to #{@desired}"
    end

    def set_autoscaling
      return unless @min || @max
      scalable_target = stack_resources.find do |r|
        r.logical_resource_id == "ScalingTarget"
      end
      register_scalable_target(scalable_target)
      to = []
      to << "min: #{@min}" if @min
      to << "max: #{@max}" if @max
      log.info "Configured autoscaling to #{to.join(" ")}"
    end

    def register_scalable_target(scalable_target)
      # service/dev/app1-web-dev-EcsService-Q0XkN6VtxGWv|ecs:service:DesiredCount|ecs
      return unless scalable_target && scalable_target.physical_resource_id # stack still creating
      resource_id, scalable_dimension, service_namespace = scalable_target.physical_resource_id.split("|")
      applicationautoscaling.register_scalable_target(
        max_capacity: @max,
        min_capacity: @min,
        resource_id: resource_id,
        scalable_dimension: scalable_dimension,
        service_namespace: service_namespace
      )
    rescue Aws::ApplicationAutoScaling::Errors::ValidationException => e
      log.error "ERROR: #{e.class} #{e.message}".color(:red)
      exit 1
    end

    def warning
      autoscaling = config.ecs.autoscaling
      return if autoscaling.manual_changes.warning == false or autoscaling.manual_changes.retain
      log.info <<~EOL
        Note: The settings are temporary
        They can be overwritten in the next: jets deploy

        You can turn off this warning with

            config.ecs.autoscaling.manual_changes.warning = false

        Or you can use the

            config.ecs.autoscaling.manual_changes.retain = true

        For considerations, see: https://ufoships.com/docs/features/autoscaling/
      EOL
    end
  end
end
