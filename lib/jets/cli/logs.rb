require "aws-logs"

class Jets::CLI
  class Logs < Base
    include EcsConcern

    def run
      options = @options.dup # so it can be modified
      options[:log_group_name] = log_group_name
      options[:since] ||= "10m" # by default, start search 10m in the past
      options[:wait_exists_retries] = 60 # 300 seconds = 300 / 5 = 60 retries
      options[:wait_exists_seconds] = 5

      verb = options[:follow] ? "Tailing" : "Showing"
      warn "#{verb} logs for #{log_group_name}"

      tail = AwsLogs::Tail.new(options)
      tail.run
    end

    def log_group_name
      log_group_name = @options[:log_group_name] # can be nil
      return log_group_name if log_group_name

      if deployment_type == "ecs"
        log_group_name_ecs
      else
        log_group_name_lambda
      end
    end

    def log_group_name_ecs
      log_group_name_ecs_params["awslogs-group"]
    end

    def log_group_name_ecs_params
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

    def log_group_name_lambda
      begin
        log_group_name = Jets::CLI::Lambda::Lookup.function("controller") # function_name
      rescue Jets::CLI::Call::Error => e
        puts "ERROR: #{e.message}"
        abort "Unable to determine log group name by looking it up. Can you double check it?"
      end

      unless log_group_name.include?(parent_stack_name)
        log_group_name = "#{parent_stack_name}-#{log_group_name}"
      end

      unless log_group_name.include?("aws/lambda")
        log_group_name = "/aws/lambda/#{log_group_name}"
      end

      log_group_name
    end
  end
end
