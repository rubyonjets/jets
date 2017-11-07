class Jets::Cfn::Mappers
  class EventsRuleMapper
    # task is a Jets::Job::Task
    def initialize(task)
      @task = task
    end

    # Example: "ScheduledEventHardJobDig"
    def logical_id
      "#{full_task_name}ScheduledEvent"
    end

    # Example: "HardJobDigLambdaFunction"
    def lambda_function_logical_id
      "#{full_task_name}LambdaFunction"
    end

    # Target Id: A unique, user-defined identifier for the target. Acceptable values include alphanumeric characters, periods (.), hyphens (-), and underscores (_).
    #
    # Example: RuleTargetHardJobDig
    def rule_target_id
      "#{full_task_name}RuleTarget"
    end

    # Example: HardJobDigPermissionEventsRule
    def permission_logical_id
      "#{full_task_name}PermissionEventsRule"
    end

  private
    # Full camelized task name including the class
    # Example: HardJobDig
    def full_task_name
      class_name = @task.class_name # already camelized
      task_name = @task.meth.to_s.camelize
      "#{class_name}#{task_name}"
    end
  end
end

