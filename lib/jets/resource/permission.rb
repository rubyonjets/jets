module Jets::Resource
  class Permission
    extend Memoist

    def initialize(task)
      @task = task
    end

    # TODO: auto-detect using the principal from the associated resource
    # replacements for: logical_id, function_name, source_arn
    def resource
      attributes = {
        "{namespace}Permission" => {
          type: "AWS::Lambda::Permission",
          properties: {
            function_name: "!GetAtt {namespace}EventsRulePermission.Arn",
            action: "lambda:InvokeFunction",
            principal: "events.amazonaws.com",
            source_arn: "!GetAtt {namespace}ScheduledEvent.Arn"
          }
        }
      }
      Attributes.new(attributes, @task)
    end
    memoize :resource
  end
end
