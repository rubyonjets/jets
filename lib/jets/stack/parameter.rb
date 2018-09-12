class Jets::Stack
  class Parameter
    autoload :Dsl, "jets/stack/parameter/dsl"
    include Base

    # TODO: Move to properly class after figure out how it works
    def build
      definition = standarize(@definition)
    end

    def standarize(definition)
      first, second, _ = defintion
      if defintion.size == 1 && first.is_a?(Hash) # long form

      elsif defintion.size == 2 && second.is_a?(Hash) # medium form

      elsif defintion.size == 2 && (second.is_a?(String) || second.is_a?(NilClass)) # short form

      else # I dont know what form
        raise "Invalid form provided. definition #{definition.inspect}"
      end

      definition
    end

    # def self.build
    #   definitions.each do |definition|

    #   end
    # end
  end
end
