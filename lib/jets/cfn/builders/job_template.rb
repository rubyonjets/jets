class Jets::Cfn::Builders
  class JobTemplate < ChildTemplate
    def compose
      add_common_parameters
      add_functions
      add_scheduled_tasks
    end

    def add_scheduled_tasks
      # @app_class example: HardJob
      @app_class.all_tasks.each do |task|
        map = Jets::Cfn::Mappers::EventsRuleMapper.new(task)

        add_event_rule(task, map)
        add_permission(map)
      end
    end


    def add_event_rule(task, map)
      add_resource(map.logical_id, "AWS::Events::Rule",
        ScheduleExpression: task.schedule_expression,
        State: "ENABLED",
        Targets: [
          {
            Arn: "!GetAtt #{map.lambda_function_logical_id}.Arn",
            Id: map.rule_target_id
          }
        ]
      )
      # Example:
      # add_resource("ScheduledEventHardJobDig", "AWS::Events::Rule",
      #   ScheduleExpression: "rate(1 minute)",
      #   State: "ENABLED",
      #   Targets: [
      #     {
      #       Arn: "!GetAtt HardJobDigLambdaFunction.Arn",
      #       Id: "RuleTargetHardJobDig"
      #     }
      #   ]
      # )
    end

    def add_permission(map)
      # HelloLambdaPermissionEventsRuleSchedule1:
      #   Type: AWS::Lambda::Permission
      #   Properties:
      #     FunctionName:
      #       Fn::GetAtt:
      #       - HelloLambdaFunction
      #       - Arn
      #     Action: lambda:InvokeFunction
      #     Principal: events.amazonaws.com
      #     SourceArn:
      #       Fn::GetAtt:
      #       - HelloEventsRuleSchedule1
      #       - Arn
    end

  end
end

