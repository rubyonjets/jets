class Jets::CLI::Ps
  class Task < Jets::CLI::Base
    def initialize(options = {})
      super
      @task = options[:task] # task response from ecs.list_tasks
    end

    def to_a
      [id, name, release, started, status, notes]
    end

    def id
      @task["task_arn"].split("/").last.split("-").first
    end

    def name
      container_overrides = @task.dig("overrides", "container_overrides")
      overrides = container_overrides # assume first is one we want
      if !overrides.empty? # PENDING wont yet have info
        overrides.map { |i| i["name"] }.join(",")
      else
        container_names
      end
    rescue NoMethodError
      container_names
    end

    # PENDING wont yet have any containers yet but since using task definition we're ok
    def container_names
      task_definition = task_definition(@task.task_definition_arn)
      names = task_definition.container_definitions.map do |container_definition|
        container_definition.name
      end
      names.join(",")
    end

    # ECS inconsistently returns the container names in random order
    # Look up the names from the task definition to try and get right order
    # This still seems to return inconsistently.
    # IE: Not the order that was defined in the task definition originally
    def task_definition(task_definition_arn)
      resp = ecs.describe_task_definition(
        task_definition: task_definition_arn
      )
      resp.task_definition
    end
    memoize :task_definition

    def container_instance_arn
      @task["container_instance_arn"].split("/").last
    end

    def release
      @task["task_definition_arn"].split("/").last
    end

    def started
      started = time(@task["started_at"])
      return "PENDING" unless started
      relative_time(started)
    end

    def time(value)
      Time.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    # hide stopped tasks have been stopped for more than 5 minutes
    #  created_at=2018-07-05 21:52:13 -0700,
    #  started_at=2018-07-05 21:52:15 -0700,
    #  stopping_at=2018-07-05 22:03:44 -0700,
    #  stopped_at=2018-07-05 22:03:45 -0700,
    def hide?
      return false if @options[:status] == "stopped"
      # Went back and forth with stopped_at vs started_at
      # Seems like stopped_at is better as when ECS is trying to scale it leaves a lot of tasks
      stopped_at = time(@task["stopped_at"])
      return false unless stopped_at
      time = Time.now - 60 * Ufo.config.ps.hide_age
      status == "STOPPED" && stopped_at < time
    end

    def status
      @task["last_status"]
    end

    # Grab all the reasons and surface to user.
    # Even though will make the table output ugly, debugging info merits it.
    #
    #     ufo ps --format json
    #
    def notes
      return unless @task["stopped_reason"]
      notes = []
      notes << "Task Stopped Reason: #{@task["stopped_reason"]}."
      @task.containers.each do |container|
        notes << "Container #{container.name} reason: #{container.reason}" unless container.reason.blank?
      end
      notes.join(" ")
    end

    # https://stackoverflow.com/questions/195740/how-do-you-do-relative-time-in-rails/195894
    def relative_time(start_time)
      diff_seconds = Time.now - start_time
      case diff_seconds
      when 0..59
        "#{diff_seconds.to_i} seconds ago"
      when 60..(3600 - 1)
        "#{(diff_seconds / 60).to_i} minutes ago"
      when 3600..(3600 * 24 - 1)
        "#{(diff_seconds / 3600).to_i} hours ago"
      when (3600 * 24)..(3600 * 24 * 30)
        "#{(diff_seconds / (3600 * 24)).to_i} days ago"
      else
        start_time.strftime("%m/%d/%Y")
      end
    end

    class << self
      def header
        %w[Task Name Release Started Status Notes]
      end
    end
  end
end
