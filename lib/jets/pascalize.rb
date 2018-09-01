module Jets
  class Pascalize
    class << self
      # Specialized pascalize that will not pascalize keys under the
      # Variables part of the hash structure.
      # Based on: https://stackoverflow.com/questions/8706930/converting-nested-hash-keys-from-camelcase-to-snake-case-in-ruby
      def pascalize(value, parent_keys=[])
        case value
          when Array
            value.map { |v| pascalize(v) }
          when Hash
            initializer = value.map do |k, v|
              new_key = pascal_key(k, parent_keys)
              [new_key, pascalize(v, parent_keys+[new_key])]
            end
            Hash[initializer]
          else
            value
         end
      end

      def pascal_key(k, parent_keys=[])
        if parent_keys.include?("Variables") # do not pascalize keys anything under Variables
          k.to_s
        elsif parent_keys.last == "EventPattern" # top-level
          k.to_s.dasherize
        elsif parent_keys.include?("EventPattern")
          # any keys at 2nd level under EventPattern will be camelize
          key = k.to_s.camelize # an earlier pascalize has made the first char upcase
          # so we need to downcase it again
          first_char = key[0..0].downcase
          key[0] = first_char
          key
        else
          pascalize_string(k)
        end
      end

      def pascalize_string(s)
        s = s.to_s.camelize
        s.slice(0,1).capitalize + s.slice(1..-1) # capitalize first letter only
      end
    end
  end
end