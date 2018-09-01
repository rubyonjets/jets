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
        SecurityJobDisableUnusedCredentialsEventsRulePermission: {
          type: "AWS::Lambda::Permission",
          properties: {
            function_name: "LAMBDA_PERMISSION_ARN",
            action: "lambda:InvokeFunction",
            principal: "events.amazonaws.com",
            source_arn: "SOURCE_ARN"
          }
        }
      }
      Attributes.new(attributes, @task)
    end
    memoize :resource
  end
end
