class Jets::Stack
  class Resource
    module Dsl
      extend ActiveSupport::Concern

      def resources
        Resource.definitions(self.class)
      end

      included do
        class << self
          def resource(*definition)
            # self is subclass is the stack that inherits from Jets::Stack
            # IE: ExampleStack < Jets::Stack
            Resource.new(self, *definition).register
          end
        end
      end
    end
  end
end
