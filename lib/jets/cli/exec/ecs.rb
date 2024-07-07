class Jets::CLI::Exec
  class Ecs < Jets::CLI::Base
    include Jets::CLI::EcsConcern
    delegate :config, to: "Jets.project"

    def execute
      check_install!
      parent_stack = find_stack(parent_stack_name)
      unless parent_stack
        log.error "Stack not found: #{parent_stack_name}".color(:red)
        exit 1
      end

      unless ecs_service # brand new deploy
        log.error "ECS Service not yet available".color(:red)
        log.info "Try again in a little bit"
        exit 1
      end

      running = service_tasks.select do |task|
        task.last_status == "RUNNING"
      end
      if running.empty?
        log.info "No running tasks found to exec into"
        return
      end

      tasks = running.sort_by { |t| t.started_at }
      task = tasks.last # most recent

      task_name = task.task_arn.split("/").last
      execute_command(
        cluster: ecs_cluster_name,
        task: task_name,
        container: container(task), # only required if multiple containers in a task
        interactive: true,
        command: command
      )
    end

    def command
      @options[:command].empty? ? config.exec.ecs.command : @options[:command].join(" ")
    end

    def container(task)
      return @options[:container] if @options[:container]
      containers = task.containers
      container = containers.find do |c|
        c.name == @options[:role]
      end
      container ||= containers.first  # assume first task if not roles match
      container&.name
    end

    def execute_command(options = {})
      args = options.inject("") do |args, (k, v)|
        arg = (k == :interactive) ? "--#{k}" : "--#{k} #{v}"
        args += " #{arg}"
      end
      sh "aws ecs execute-command#{args}"
    end

    def service_tasks
      service_name = ecs_service.service_name
      all_task_arns = ecs.list_tasks(cluster: ecs_cluster_name, service_name: service_name).task_arns
      return [] if all_task_arns.empty?
      ecs.describe_tasks(cluster: ecs_cluster_name, tasks: all_task_arns).tasks
    end

    def sh(command)
      puts "=> #{command}"
      Kernel.exec command
    end

    def check_install!
      # check_session_manager_plugin!
      check_aws_cli!
    end

    def check_session_manager_plugin!
      installed = system "type session-manager-plugin > /dev/null 2>&1"
      return if installed
      log.error "ERROR: The Session Manager plugin required to use jets exec".color(:red)
      exit 1
    end

    def check_aws_cli!
      installed = system "type aws > /dev/null 2>&1"
      return if installed
      log.error "ERROR: aws cli is required to use jets exec".color(:red)
      exit 1
    end
  end
end
