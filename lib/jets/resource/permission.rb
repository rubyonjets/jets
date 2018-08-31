module Jets::Resource
  class Permission
    extend Memoist

    def initialize(task)
      @task = task
    end

    def resource
      attributes = {
        LOGICAL_ID: {
          type: "AWS::Lambda::Permission",
          properties: {
            function_name: "LAMBDA_PERMISSION_ARN",
            action: "lambda:InvokeFunction",
            principal: "events.amazonaws.com", # todo: auto-detect using the definition
            source_arn: "SOURCE_ARN"
          }
        }
      }
      Attributes.new(attributes, @task)
    end
    memoize :resource
  end
end
