class Jets::Resource
  class Permission
    extend Memoist

    def initialize(task, resource)
      @task = task
      @resource_attributes = resource
    end

    def attributes
      logical_id = "{namespace}Permission"
      md = @resource_attributes.logical_id.match(/(\d+)/)
      if md
        counter = md[1]
      end
      logical_id = [logical_id, counter].compact.join('')

      attributes = {
        logical_id => {
          type: "AWS::Lambda::Permission",
          properties: {
            function_name: "!GetAtt {namespace}LambdaFunction.Arn",
            action: "lambda:InvokeFunction",
            principal: principal,
            source_arn: source_arn,
          }
        }
      }
      Attributes.new(attributes, @task)
    end
    memoize :attributes

    # Auto-detect principal from the associated resources.
    def principal
      Replacer.principal_map(@resource_attributes.type)
    end

    def source_arn
      default_arn = "!GetAtt #{@resource_attributes.logical_id}.Arn"
      Replacer.source_arn_map(@resource_attributes.type) || default_arn
    end
  end
end
