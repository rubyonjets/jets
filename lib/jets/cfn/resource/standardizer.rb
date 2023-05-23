class Jets::Cfn::Resource
  class Standardizer
    include Jets::Util::Camelize

    attr_reader :definition
    def initialize(*definition)
      @definition = definition.flatten
    end

    def template
      camelize(standarize(@definition))
    end

    def standarize(definition)
      definition = camelize(definition)
      first, second, third, _ = definition
      if definition.size == 1 && first.is_a?(Hash) # long form
        first # pass through
      elsif definition.size == 2 && second.is_a?(Hash) # medium form
        logical_id, attributes = first, second
        attributes.delete(:Properties) if attributes[:Properties].nil? || attributes[:Properties].empty?
        { logical_id => attributes }
      elsif definition.size == 2 && second.is_a?(String) # short form
        logical_id, type = first, second
        { logical_id => {
            Type: type
        }}
      elsif definition.size == 3 && (second.is_a?(String) || second.is_a?(NilClass))# short form
        logical_id, type, properties = first, second, third
        template = { logical_id => {
                       Type: type
                    }}
        attributes = template.values.first
        attributes[:Properties] = properties unless properties.empty?
        template
      else # Dont understand this form
        raise "Invalid form provided. definition #{definition.inspect}"
      end
    end
  end
end