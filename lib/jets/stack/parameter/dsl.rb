class Jets::Stack
  class Parameter
    module Dsl
      def parameters
        Parameter.definitions
      end

      # TODO: use ActiveSuport concerns instead
      def self.included(base)
        base.extend DslMethods
      end

      module DslMethods
        def parameter(*definition)
          Parameter.new(*definition).register
        end
      end
    end
  end
end
