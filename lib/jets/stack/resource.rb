class Jets::Stack
  class Resource
    autoload :Dsl, "jets/stack/resource/dsl"
    include Base

    def template
      camelize(standarize(@definition))
    end

    # Value is the only required property: https://amzn.to/2xbhmk3
    def standarize(definition)
      first, second, third, _ = definition
      if definition.size == 1 && first.is_a?(Hash) # long form
        first # pass through
      elsif definition.size == 2 && second.is_a?(Hash) # medium form
        logical_id, properties = first, second
        { logical_id => properties }
      elsif definition.size == 3 && second.is_a?(String) # short form
        logical_id = first
        type = second
        properties = third
        { logical_id => {
            type: type,
            properties: properties
        }}
      else # I dont know what form
        raise "Invalid form provided. definition #{definition.inspect}"
      end
    end
  end
end
