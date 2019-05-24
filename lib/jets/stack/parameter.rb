# Implements:
#
#   template - uses @definition to build a CloudFormation template section
#
class Jets::Stack
  class Parameter
    include Definition

    def template
      camelize(add_required(standarize(@definition)))
    end

    # Type is the only required property: https://amzn.to/2x8W5aD
    def standarize(definition)
      first, second, _ = definition
      if definition.size == 1 && first.is_a?(Hash) # long form
        first # pass through
      elsif definition.size == 2 && second.is_a?(Hash) # medium form
        logical_id, properties = first, second
        { logical_id => properties }
      elsif (definition.size == 2 && second.is_a?(String)) || # short form
            definition.size == 1
        logical_id = first
        properties = second.is_a?(String) ? { default: second } : {}
        { logical_id => properties }
      else # I dont know what form
        raise "Invalid form provided. definition #{definition.inspect}"
      end
    end

    def add_required(attributes)
      properties = attributes.values.first
      properties[:type] ||= 'String'
      attributes
    end
  end
end
