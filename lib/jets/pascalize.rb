module Jets
  class Pascalize
    class << self
      # Specialized pascalize that will not pascalize keys under the
      # Variables part of the hash structure.
      # Based on: https://stackoverflow.com/questions/8706930/converting-nested-hash-keys-from-camelcase-to-snake-case-in-ruby
      def pascalize(value, parent_key=nil)
        case value
          when Array
            value.map { |v| pascalize(v) }
          when Hash
            initializer = value.map do |k, v|
              new_key = pascal_key(k, parent_key)
              [new_key, pascalize(v, new_key)]
            end
            Hash[initializer]
          else
            value
         end
      end

      def pascal_key(k, parent_key=nil)
        if parent_key == "Variables" # do not pascalize keys anything under Variables
          k
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