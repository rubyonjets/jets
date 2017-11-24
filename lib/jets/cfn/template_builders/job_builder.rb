class Jets::Cfn::TemplateBuilders
  class JobBuilder < BaseChildBuilder
    def compose
      add_common_parameters
      add_functions
      add_scheduled_tasks
    end

    def add_scheduled_tasks
      # @app_klass is PostsController, HardJob, Hello, or HelloFunction
      @app_klass.tasks.each do |task|
        map = Jets::Cfn::TemplateMappers::EventsRuleMapper.new(task)

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
      add_resource(map.permission_logical_id, "AWS::Lambda::Permission",
        FunctionName: "!GetAtt #{map.lambda_function_logical_id}.Arn",
        Action: "lambda:InvokeFunction",
        Principal: "events.amazonaws.com",
        SourceArn: "!GetAtt #{map.logical_id}.Arn"
      )
      # Example:
      # add_resource("HardJobDigPermissionEventsRule", "AWS::Lambda::Permission",
      #   FunctionName: "!GetAtt HardJobDigLambdaFunction.Arn",
      #   Action: "lambda:InvokeFunction",
      #   Principal: "events.amazonaws.com",
      #   SourceArn: "!GetAtt ScheduledEventHardJobDig.Arn"
      # )
    end
  end
end

