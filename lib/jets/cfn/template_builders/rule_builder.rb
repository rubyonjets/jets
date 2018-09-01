class Jets::Cfn::TemplateBuilders
  class RuleBuilder < BaseChildBuilder
    def compose
      add_common_parameters
      add_functions
      add_resources
    end

    def add_resources
      @app_klass.tasks.each do |task|
        task.resources.each do |definition|
          creator = Jets::Resource::Creator.new(definition, task)
          add_associated_resource(creator.resource)
          add_associated_resource(creator.permission.resource)
        end
      end

      # Handle config_rules associated with aws managed rules.
      # List of AWS Config Managed Rules: https://amzn.to/2BOt9KN
      @app_klass.managed_rules.each do |rule|
        map = Jets::Cfn::TemplateMappers::ConfigRuleMapper.new(rule)
        add_aws_managed_rule(rule, map)
      end
    end

    def add_associated_resource(resource)
      add_resource(resource.logical_id, resource.type, resource.properties)
    end

    def add_aws_managed_rule(rule, map)
      # Usually we build the properties with the mappers but in the case for
      # a config_rule it makes more sense to grab properties from the task
      # using config_rule_properties
      add_resource(map.logical_id, "AWS::Config::ConfigRule",
        Properties: rule.config_rule_properties
      )
    end

    def add_config_rule(task, map)
      # Usually we build the properties with the mappers but in the case for
      # a config_rule it makes more sense to grab properties from the task
      # using config_rule_properties
      add_resource(map.logical_id, "AWS::Config::ConfigRule",
        Properties: task.config_rule_properties,
        DependsOn: map.permission_logical_id
      )
      # Example:
      # add_resource("GameRuleProtectConfigRule", "AWS::Config::ConfigRule",
      #   "ConfigRuleName" : String,
      #   "Description" : String,
      #   "InputParameters" : { ParameterName : Value },
      #   "MaximumExecutionFrequency" : String,
      #   "Scope" : Scope,
      #   "Source" : Source
      # )
    end

    def add_permission(map)
      add_resource(map.permission_logical_id, "AWS::Lambda::Permission",
        FunctionName: "!GetAtt #{map.lambda_function_logical_id}.Arn",
        Action: "lambda:InvokeFunction",
        Principal: "config.amazonaws.com"
      )
      # Example:
      # add_resource("GameRuleProtectConfigRulePermission", "AWS::Lambda::Permission",
      #   FunctionName: "!GetAtt GameRuleProtectLambdaFunction.Arn",
      #   Action: "lambda:InvokeFunction",
      #   Principal: "config.amazonaws.com",
      #   SourceArn: "!GetAtt ScheduledEventHardRuleDig.Arn"
      # )
    end
  end
end

