class Jets::CLI
  class Scale < Jets::CLI::Base
    include EcsConcern
    delegate :config, to: "Jets.project"

    def initialize(options = {})
      super
      @desired = options[:desired]
      @min = options[:min]
      @max = options[:max]
    end

    def update
      unless service
        log.error "ERROR: Unable to find ECS service for #{parent_stack_name}".color(:red)
        log.error "Are you sure you it's deployed?"
        exit 1
      end

      unless @desired || @min || @max
        log.info <<~EOL
          No --desired --min or --max options provided
          Not taking any actions
        EOL
        return
      end

      log.info "Configuring ECS scaling settings for #{parent_stack_name}"
      set_desired_count
      set_autoscaling
      warning
    end

    def set_desired_count
      return unless @desired
      ecs.update_service(
        service: ecs_service.service_name,
        cluster: ecs_cluster_name,
        desired_count: @desired
      )
      log.info "Configured desired count to #{@desired}"
    end

    def set_autoscaling
      return unless @min || @max
      scalable_target = ecs_stack_resources.find do |r|
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
      return unless scalable_target&.physical_resource_id # stack still creating
      resource_id, scalable_dimension, service_parent_stack_name = scalable_target.physical_resource_id.split("|")
      applicationautoscaling.register_scalable_target(
        max_capacity: @max,
        min_capacity: @min,
        resource_id: resource_id,
        scalable_dimension: scalable_dimension,
        service_parent_stack_name: service_parent_stack_name
      )
    rescue Aws::ApplicationAutoScaling::Errors::ValidationException => e
      log.error "ERROR: #{e.class} #{e.message}".color(:red)
      exit 1
    end

    def warning
      return if config.scale.manual_changes.warning == false || config.scale.manual_changes.retain
      log.info <<~EOL
        Note: The settings are temporary
        They can be overwritten in the next: jets deploy

        You can turn off this warning with

            config.scale.manual_changes.warning = false

        Or you can use the

            config.scale.manual_changes.retain = true

        For considerations, see: https://rubyonjets.com/docs/ecs/autoscaling/
      EOL
    end
  end
end
