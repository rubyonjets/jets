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
        attrs = first.values.first
        remove_nil_properties!(attrs)
        first # pass through
      elsif definition.size == 2 && second.is_a?(Hash) # medium form
        logical_id, attrs = first, second
        remove_nil_properties!(attrs)
        {logical_id => attrs}
      elsif definition.size == 2 && second.is_a?(String) # short form
        logical_id, type = first, second
        {logical_id => {
          Type: type
        }}
      elsif definition.size == 3 && (second.is_a?(String) || second.is_a?(NilClass)) # short form
        logical_id, type, properties = first, second, third
        template = {logical_id => {
          Type: type
        }}
        attrs = template.values.first
        attrs[:Properties] = properties unless properties.empty?
        remove_nil_properties!(attrs)
        template
      else # Dont understand this form
        raise "Invalid form provided. definition #{definition.inspect}"
      end
    end

    def remove_nil_properties!(attrs)
      return attrs unless attrs[:Properties]
      if attrs[:Properties].blank?
        attrs.delete(:Properties) # remove empty Properties
      else
        attrs[:Properties].delete_if { |k, v| v.nil? } # remove nil values
      end
      attrs
    end
  end
end
