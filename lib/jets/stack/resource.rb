# Implements:
#
#   template - uses @definition to build a CloudFormation template section
#
class Jets::Stack
  class Resource
    autoload :Dsl, "jets/stack/resource/dsl"
    include Base

    def template
      camelize(standarize(@definition))
    end

    # CloudFormation Resources reference: https://amzn.to/2NKg6ip
    def standarize(definition)
      first, second, third, _ = definition
      if definition.size == 1 && first.is_a?(Hash) # long form
        first # pass through
      elsif definition.size == 2 && second.is_a?(Hash) # medium form
        logical_id, attributes = first, second
        attributes.delete(:properties) if attributes[:properties].nil? || attributes[:properties].empty?
        { logical_id => attributes }
      elsif definition.size == 2 && second.is_a?(String) # short form
        logical_id, type = first, second
        { logical_id => {
            type: type
        }}
      elsif definition.size == 3 && (second.is_a?(String) || second.is_a?(NilClass))# short form
        logical_id, type, properties = first, second, third
        template = { logical_id => {
                       type: type
                    }}
        attributes = template.values.first
        attributes[:properties] = properties unless properties.empty?
        template
      else # I dont know what form
        raise "Invalid form provided. definition #{definition.inspect}"
      end
    end
  end
end
