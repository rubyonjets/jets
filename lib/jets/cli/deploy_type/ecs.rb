class Jets::CLI::DeployType
  class Ecs < Base
    include Jets::CLI::EcsConcern

    def log_group_name
      log_group_name_params["awslogs-group"]
    end

    def log_group_name_params
      unless ecs_service
        log.info "Cannot find stack: #{parent_stack_name}"
        exit 1
      end
      task_definition = ecs_service.task_definition
      resp = ecs.describe_task_definition(task_definition: task_definition)

      container_definitions = resp.task_definition.container_definitions

      if container_definitions.size > 1 && !@options[:container]
        log.info "Multiple containers found. ufo logs will use the first container."
        log.info "You can also use the --container option to set the container to use."
      end

      definition = if @options[:container]
        container_definitions.find do |c|
          c.name == @options[:container]
        end
      else
        container_definitions.first
      end

      unless definition
        log.error "ERROR: unable to find a container".color(:red)
        log.error "You specified --container #{@options[:container]}" if @options[:container]
        exit 1
      end

      log_conf = definition.log_configuration
      unless log_conf
        log.error "ERROR: Unable to find a log_configuration for container: #{definition.name}".color(:red)
        log.error "You specified --container #{@options[:container]}" if @options[:container]
        exit 1
      end

      if log_conf.log_driver == "awslogs"
        # options["awslogs-group"]
        # options["awslogs-region"]
        # options["awslogs-stream-prefix"]
        log_conf.options
      else
        log.error "ERROR: Only supports awslogs driver. Detected log_driver: #{log_conf.log_driver}".color(:red)
        exit 1 unless ENV["JETS_TEST"]
      end
    end
  end
end
