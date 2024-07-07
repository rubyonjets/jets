require "aws-logs"

class Jets::CLI
  class Logs < Base
    include Jets::AwsServices::AwsHelpers

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

    def deployment_type
      "ecs" # TODO: implement
    end

    def log_group_name_ecs
      unless ecs_service
        logger.info "Cannot find stack: #{namespace}"
        exit 1
      end
      task_definition = info.service.task_definition
      resp = ecs.describe_task_definition(task_definition: task_definition)

      container_definitions = resp.task_definition.container_definitions

      if container_definitions.size > 1 && !@options[:container]
        logger.info "Multiple containers found. ufo logs will use the first container."
        logger.info "You can also use the --container option to set the container to use."
      end

      definition = if @options[:container]
        container_definitions.find do |c|
          c.name == @options[:container]
        end
      else
        container_definitions.first
      end

      unless definition
        logger.error "ERROR: unable to find a container".color(:red)
        logger.error "You specified --container #{@options[:container]}" if @options[:container]
        exit
      end

      log_conf = definition.log_configuration
      unless log_conf
        logger.error "ERROR: Unable to find a log_configuration for container: #{definition.name}".color(:red)
        logger.error "You specified --container #{@options[:container]}" if @options[:container]
        exit 1
      end

      if log_conf.log_driver == "awslogs"
        # options["awslogs-group"]
        # options["awslogs-region"]
        # options["awslogs-stream-prefix"]
        log_conf.options
      else
        logger.error "ERROR: Only supports awslogs driver. Detected log_driver: #{log_conf.log_driver}".color(:red)
        exit 1 unless ENV["UFO_TEST"]
      end
    end

    def log_group_name_lambda
      begin
        log_group_name = Jets::CLI::Lambda::Lookup.function("controller") # function_name
      rescue Jets::CLI::Call::Error => e
        puts "ERROR: #{e.message}"
        abort "Unable to determine log group name by looking it up. Can you double check it?"
      end

      unless log_group_name.include?(Jets.project.namespace)
        log_group_name = "#{Jets.project.namespace}-#{log_group_name}"
      end

      unless log_group_name.include?("aws/lambda")
        log_group_name = "/aws/lambda/#{log_group_name}"
      end

      log_group_name
    end
  end
end
