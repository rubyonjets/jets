class Jets::Resource
  class Permission < Jets::Resource::Base
    def initialize(replacements, associated_resource)
      @replacements = replacements
      @associated_resource = associated_resource
    end

    def definition
      logical_id = permission_logical_id

      definition = {
        logical_id => {
          type: "AWS::Lambda::Permission",
          properties: {
            function_name: "!GetAtt {namespace}LambdaFunction.Arn",
            action: "lambda:InvokeFunction",
            principal: principal
          }
        }
      }

      # From AWS docs: https://amzn.to/2N0QXQL
      # source_arn is "not supported by all event sources"
      definition[logical_id][:properties][:source_arn] = source_arn if source_arn

      definition
    end

    def permission_logical_id
      logical_id = "{namespace}_permission"
      md = @associated_resource.logical_id.match(/(\d+)$/)
      counter = md[1] if md
      [logical_id, counter].compact.join('').underscore
    end

    # Auto-detect principal from the associated resources.
    def principal
      Replacer.principal_map(@associated_resource.type)
    end

    def source_arn
      Replacer.source_arn_map(@associated_resource.type)
    end
  end
end
