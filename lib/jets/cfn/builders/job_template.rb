class Jets::Cfn::Builders
  class JobTemplate < ChildTemplate
    def compose
      add_common_parameters
      add_functions
      add_scheduled_jobs
    end

    def add_scheduled_jobs
      scoped_jobs.each do |job|
        map = EventsRuleMapper.new(job)

        add_event_rule(job, map)
        add_permission(map)
      end
    end

    def add_event_rule(job, map)
      HelloEventsRuleSchedule1:
        Type: AWS::Events::Rule
        Properties:
          ScheduleExpression: job.schedule_expression # rate(1 minute)
          State: ENABLED
          Targets:
          - Arn:
              Fn::GetAtt:
              - HelloLambdaFunction
              - Arn
            Id: helloSchedule
    end

    def add_permission(map)
      HelloLambdaPermissionEventsRuleSchedule1:
        Type: AWS::Lambda::Permission
        Properties:
          FunctionName:
            Fn::GetAtt:
            - HelloLambdaFunction
            - Arn
          Action: lambda:InvokeFunction
          Principal: events.amazonaws.com
          SourceArn:
            Fn::GetAtt:
            - HelloEventsRuleSchedule1
            - Arn
    end

    def scoped_jobs
      schedule_yml = "#{Jets.root}config/schedule.yml"
      return [] unless File.exist?(schedule_yml)

      jobs = []
      schedule = YAML.load_file(schedule_yml)
      schedule.keys.each do |class_plus_method| # EasyJob#sleep
        class_name, method = class_plus_method.split('#')
        if class_name == @child_class.to_s
          jobs << Jets::Job.new(class_plus_method, schedule[class_plus_method])
        end
      end
      jobs
    end
  end
end

