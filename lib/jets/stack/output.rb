# Implements:
#
#   template - uses @definition to build a CloudFormation template section
#
class Jets::Stack
  class Output
    include Definition

    def template
      camelize(standarize(@definition))
    end

    # Value is the only required property: https://amzn.to/2xbhmk3
    def standarize(definition)
      first, second, _ = definition
      if definition.size == 1 && first.is_a?(Hash) # long form
        first # pass through
      elsif definition.size == 2 && second.is_a?(Hash) # medium form
        logical_id, properties = first, second
        { logical_id => properties }
      elsif definition.size == 2 && second.is_a?(String) # short form
        logical_id = first
        properties = second.is_a?(String) ? { value: second } : {}
        { logical_id => properties }
      elsif definition.size == 1
        logical_id = first.to_s
        properties = {value: "!Ref #{logical_id.camelize}"}
        { logical_id => properties }
      else # I dont know what form
        raise "Invalid form provided. definition #{definition.inspect}"
      end
    end
  end
end

