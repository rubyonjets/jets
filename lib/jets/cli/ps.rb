require "text-table"
require "tty-screen"

class Jets::CLI
  class Ps < Jets::CLI::Base
    include AutoscalingConcern
    delegate :config, :namespace, to: "Jets.project"

    def run
      unless service
        parent_stack = find_stack(namespace)
        if parent_stack && parent_stack.stack_status == "CREATE_IN_PROGRESS"
          log.info "Stack is still creating. Try again after it completes"
        else
          "No stack #{namespace} found"
        end
        nil
      end

      summary

      if task_arns.empty?
        log.info "There are 0 running tasks."
        nil
      end

      all_task_arns = task_arns.each_slice(100).map do |arns|
        resp = ecs.describe_tasks(tasks: arns, cluster: @cluster)
        resp["tasks"]
      end.flatten

      tasks = show_tasks(all_task_arns)
      show_errors(tasks)
    end

    def summary
      return unless Jets.project.ps.summary

      cluster_name = service.cluster_arn.split("/").last
      data = [
        ["Stack", namespace],
        ["Service", service.service_name],
        ["Cluster", cluster_name],
        ["Status", service.status],
        ["Tasks", tasks_counts],
        ["Launch type", service.launch_type]
      ]

      presenter = CliFormat::Presenter.new(format: "info")
      data.each do |row|
        presenter.rows << row
      end
      presenter.show
    end

    def tasks_counts
      message = "Running: #{service.running_count} Desired: #{service.desired_count}"
      if scalable_target
        message += " Min: #{scalable_target.min_capacity} Max: #{scalable_target.max_capacity}"
      end
      message
    end

    def scalable_target
      return unless autoscaling_enabled?
      # Docs: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ApplicationAutoScaling/Client.html#describe_scalable_targets-instance_method
      # ECS service - The resource type is service and the unique identifier is the cluster name and service name. Example: service/default/sample-webapp.
      resource_id = "service/#{@cluster}/#{service.service_name}"
      resp = applicationautoscaling.describe_scalable_targets(
        service_namespace: "ecs",
        resource_ids: [resource_id]
      )
      resp.scalable_targets.first # scalable_target
    end

    def convert_to_task_objects(task_arns)
      task_arns.sort_by! { |t| t["task_arn"] }
      task_arns.map { |t| Task.new(@options.merge(task: t)) } # will have Task objects after this point
    end

    # Note: ufo stop also uses Ps#show_tasks. Thats why convert_to_task_objects within the method
    def show_tasks(tasks_arns)
      tasks = convert_to_task_objects(tasks_arns)
      tasks = tasks.reject(&:hide?)
      show_notes = show_notes(tasks)

      format = determine_format(tasks)
      o = @options.dup # Cant modify frozen Thor options
      o[:format] ||= format

      presenter = CliFormat::Presenter.new(o)
      header = show_notes ? Task.header : Task.header[0..-2]
      presenter.header = header
      tasks.each do |task|
        row = show_notes ? task.to_a : task.to_a[0..-2]
        presenter.rows << row
      end
      presenter.show
      tasks
    end

    def show_errors(tasks)
      Errors.new(@options.merge(tasks: tasks)).show
    end

    private

    def show_notes(tasks)
      tasks.detect { |t| !t.notes.blank? }
    end

    # auto format will display in json if the output is to wide
    # otherwise it defaults to table
    def determine_format(tasks)
      if config.ps.format == "auto"
        max = max_table_width(tasks)
        (max >= TTY::Screen.width) ? "json" : "table"
      else
        config.ps.format
      end
    end

    def max_table_width(tasks)
      max = 0
      tasks.each do |row|
        columns = row.to_a
        width = columns.inject(0) do |total, column|
          total + column.to_s.length
        end
        max = width if width >= max
      end
      padding = Task.header.size * 3 + 1
      # max full column width. accounts for all the rows plus the padding from the table output
      max + padding
    end

    def statuses
      status = @options[:status] || "ALL" # can be nil when used from ship
      status = status.upcase
      valid_statuses = %w[RUNNING PENDING STOPPED]
      all_statuses = valid_statuses + ["ALL"]
      unless all_statuses.include?(status)
        log.error "Invalid status filter provided. Please provided one of the following:"
        log.error all_statuses.map(&:downcase).join(", ")
        exit 1
      end

      (status == "ALL") ? valid_statuses : [status]
    end

    def task_arns
      threads, results = [], {}
      statuses.each do |status|
        threads << Thread.new do
          options = {
            service_name: service.service_name,
            cluster: @cluster,
            desired_status: status
          }
          # Limit display of too many stopped tasks
          options[:max_results] = 20 if status == "STOPPED"
          resp = ecs.list_tasks(options)
          results[status] = resp.task_arns
        end
      end
      threads.map(&:join)
      results.values.flatten.uniq
    end
    memoize :task_arns
  end
end
