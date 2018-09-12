class Jets::Stack
  class Parameter
    module Dsl
      def parameters
        Parameter.definitions
      end

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def parameter(*definition)
          Parameter.new(*definition).register
        end
      end
    end
  end
end
