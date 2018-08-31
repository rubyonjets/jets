module Jets::Resource
  class Mapper
    extend Memoist

    def initialize(task)
      @task = task # task that the definition belongs to
    end

    def replacements
      lambda_function_map = Jets::Cfn::TemplateMappers::LambdaFunctionMapper.new(@task)
      {
        "LAMBDA_FUNCTION_ARN": "!GetAtt #{lambda_function_map.logical_id}.Arn",
        "RULE_TARGET_ID": rule_target_id,
      }
    end

    #######################
    # TODO: THIS IS THE EVENTS MAPPER LOGICAL, DOES IT BELONG HERE???
    # Example: "HardJobDigScheduledEvent"
    def logical_id
      "#{full_task_name}ScheduledEvent"
    end

    # Example: "HardJobDigLambdaFunction"
    def lambda_function_logical_id
      "#{full_task_name}LambdaFunction"
    end

    # TODO: how to break out app class mapper specfic logical to support plugins?

    # Target Id: A unique, user-defined identifier for the target. Acceptable values include alphanumeric characters, periods (.), hyphens (-), and underscores (_).
    #
    # Example: RuleTargetHardJobDig
    def rule_target_id
      "#{full_task_name}RuleTarget"
    end

    # Example: HardJobDigEventsRulePermission
    def permission_logical_id
      "#{full_task_name}EventsRulePermission"
    end

  private
    # Full camelized task name including the class
    # Example: HardJobDig
    def full_task_name
      class_name = @task.class_name.gsub('::','')
      task_name = @task.meth.to_s.camelize
      "#{class_name}#{task_name}"
    end
  end
end
