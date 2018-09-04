class Jets::Resource
  class Permission
    extend Memoist

    def initialize(replacements, associated_resource)
      @replacements = replacements
      @associated_resource = associated_resource
    end

    def logical_id
      logical_id = "{namespace}Permission"
      md = @associated_resource.logical_id.match(/(\d+)/)
      counter = md[1] if md
      logical_id = [logical_id, counter].compact.join('')
      # replace possible {namespace} in the logical id
      logical_id = replacer.replace_value(logical_id)
      Jets::Pascalize.pascalize_string(logical_id)
    end

    def type
      attributes['Type']
    end

    def properties
      attributes['Properties']
    end

    def attributes
      attributes = {
        type: "AWS::Lambda::Permission",
        properties: {
          function_name: "!GetAtt {namespace}LambdaFunction.Arn",
          action: "lambda:InvokeFunction",
          principal: principal,
          source_arn: source_arn,
        }
      }
      attributes = replacer.replace_placeholders(attributes)
      Jets::Pascalize.pascalize(attributes)
    end
    memoize :attributes

    # Auto-detect principal from the associated resources.
    def principal
      Replacer.principal_map(@associated_resource.type)
    end

    def source_arn
      default_arn = "!GetAtt #{@associated_resource.logical_id}.Arn"
      Replacer.source_arn_map(@associated_resource.type) || default_arn
    end

    def replacer
      Replacer::Base.new(@replacements)
    end
    memoize :replacer
  end
end
