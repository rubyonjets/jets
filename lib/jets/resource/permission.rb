module Jets::Resource
  class Permission
    extend Memoist

    def initialize(task)
      @task = task
    end

    # REPLACEMENTS FOR: logical_id, function_name, source_arn
    def resource
      attributes = {
        "{namespace}Permission" => {
          type: "AWS::Lambda::Permission",
          properties: {
            function_name: "!GetAtt {namespace}EventsRulePermission.Arn",
            action: "lambda:InvokeFunction",
            principal: principal,
            source_arn: "!GetAtt {namespace}ScheduledEvent.Arn"
          }
        }
      }
      Attributes.new(attributes, @task)
    end
    memoize :resource

    # Auto-detect principal from the associated resources.
    # TODO: add ability to explicitly override principal.
    def principal
      principals = @task.resources.map do |definition|
        creator = Jets::Resource::Creator.new(definition, @task)
        principal_map[creator.resource.type]
      end
      principals.size == 1 ? principals.first : principals
    end

    # TODO: fill out logical_id to service principal map
    def principal_map
      {
        "AWS::Events::Rule" => "events.amazonaws.com",
      }
    end
  end
end
