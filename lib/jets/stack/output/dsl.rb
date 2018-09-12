class Jets::Stack
  class Output
    module Dsl
      def outputs
        Output.definitions
      end

      def self.included(base)
        base.extend DslMethods
      end

      module DslMethods
        def output(*definition)
          Output.new(*definition).register
        end
      end
    end
  end
end
