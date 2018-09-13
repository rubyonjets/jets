class Jets::Stack
  class Output
    module Dsl
      extend ActiveSupport::Concern

      def outputs
        Output.definitions(self.class)
      end

      class_methods do
        def output(*definition)
          # self is subclass is the stack that inherits from Jets::Stack
          # IE: ExampleStack < Jets::Stack
          Output.new(self, *definition).register
        end
      end
    end
  end
end
