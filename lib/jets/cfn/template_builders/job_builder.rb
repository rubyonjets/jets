class Jets::Cfn::TemplateBuilders
  class JobBuilder < BaseChildBuilder
    def compose
      add_common_parameters
      add_functions
      add_resources
      add_scheduled_tasks
    end

    #
    def add_resources
      puts "ADD_RESOURCES"
      # @app_klass.resources.each do |definition|
      #   creator = Jets::ResourceCreator.new(definition)
      #   pp creator.resource
      # end

      @app_klass.tasks.each do |task|
        puts "task: #{task}"
        task.resources.each do |definition|
          puts "definition: #{definition}"
          creator = Jets::Resource::Creator.new(definition, task)
          resource = creator.resource
          logical_id = resource.keys.first
          attributes = resource.values.first # attributes is the "resource definition"
          add_resource(logical_id, attributes['Type'], attributes['Properties'])
        end
      end
    end

    def add_scheduled_tasks
      # @app_klass is PostsController, HardJob, Hello, or HelloFunction
      @app_klass.tasks.each do |task|
        map = Jets::Cfn::TemplateMappers::EventsRuleMapper.new(task)

        # If there's no scheduled expression dont add a scheduled Events::Rule
        if task.schedule_expression
          add_event_rule(task, map)
          add_permission(map)
        end
      end
    end

    def add_event_rule(task, map)
      add_resource(map.logical_id, "AWS::Events::Rule",
        ScheduleExpression: task.schedule_expression,
        State: task.state,
        Targets: [
          {
            Arn: "!GetAtt #{map.lambda_function_logical_id}.Arn",
            Id: map.rule_target_id
          }
        ]
      )
      # Example:
      # add_resource("HardJobDigScheduledEvent", "AWS::Events::Rule",
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
      # add_resource("HardJobDigEventsRulePermission", "AWS::Lambda::Permission",
      #   FunctionName: "!GetAtt HardJobDigLambdaFunction.Arn",
      #   Action: "lambda:InvokeFunction",
      #   Principal: "events.amazonaws.com",
      #   SourceArn: "!GetAtt HardJobDigScheduledEvent.Arn"
      # )
    end
  end
end

