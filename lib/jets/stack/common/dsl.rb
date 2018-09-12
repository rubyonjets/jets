class Jets::Stack
  class Common
    module Dsl
      def self.included(base)
        base.extend DslMethods
      end

      module DslMethods
        def ref(value)
          "!Ref #{value}"
        end
      end
    end
  end
end
