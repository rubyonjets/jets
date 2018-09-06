# Custom Camelizer with CloudFormation specific handling.
# Based on: https://stackoverflow.com/questions/8706930/converting-nested-hash-keys-from-camelcase-to-snake-case-in-ruby
module Jets
  class Camelizer
    class << self
      def transform(value, parent_keys=[])
        case value
        when Array
          value.map { |v| transform(v) }
        when Hash
          initializer = value.map do |k, v|
            new_key = camelize_key(k, parent_keys)
            [new_key, transform(v, parent_keys+[new_key])]
          end
          Hash[initializer]
        else
          camelize(value)
         end
      end

      def camelize_key(k, parent_keys=[])
        k = k.to_s

        if passthrough?(k, parent_keys)
          k # pass through untouch
        elsif parent_keys.last == "EventPattern" # top-level
          k.dasherize
        elsif parent_keys.include?("EventPattern")
          # Any keys at 2nd level under EventPattern will be pascalized
          new_k = k.camelize # an earlier transform has made the first char upcase
          # so we need to downcase it again
          first_char = new_k[0..0].downcase
          new_k[0] = first_char
          new_k
        else
          camelize(k)
        end
      end

      def passthrough?(k, parent_keys)
        parent_keys.include?("Variables") || # do not transform keys anything under Variables
        parent_keys.include?("ResponseParameters") || # do not transform keys anything under Variables
        k.include?('-') || k.include?('/')
      end

      def camelize(value)
        return value if value.is_a?(Integer)

        value = value.to_s.camelize
        # s = s.slice(0,1).capitalize + s.slice(1..-1) # capitalize first letter only
        special_map[value] || value
      end

      # Some keys have special mappings
      def special_map
        {
          "TemplateUrl" => "TemplateURL"
        }
      end
    end
  end
end