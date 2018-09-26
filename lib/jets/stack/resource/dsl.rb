class Jets::Stack
  class Resource
    module Dsl
      extend ActiveSupport::Concern

      def resources
        Resource.definitions(self.class)
      end

      class_methods do
        def resource(*definition)
          # self is subclass is the stack that inherits from Jets::Stack
          # IE: ExampleStack < Jets::Stack
          Resource.new(self, *definition).register
        end
      end
    end
  end
end
