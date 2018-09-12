class Jets::Stack
  class Parameter
    autoload :Dsl, "jets/stack/parameter/dsl"
    include Base

    def template
      standarize(@definition)
    end

    def standarize(definition)
      first, second, _ = definition
      if definition.size == 1 && first.is_a?(Hash) # long form
        # puts "long form detected"
        first # pass through
      elsif definition.size == 2 && second.is_a?(Hash) # medium form
        # puts "medium form detected"
        logical_id, attributes = first, second
        { logical_id => attributes }
      elsif definition.size == 2 && (second.is_a?(String) || second.is_a?(NilClass)) # short form
        # puts "short form detected"
        logical_id = first
        attributes = second.is_a?(String) ? { default: second } : {}
        { logical_id => attributes }
      else # I dont know what form
        raise "Invalid form provided. definition #{definition.inspect}"
      end
    end
  end
end
