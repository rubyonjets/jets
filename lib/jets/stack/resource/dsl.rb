class Jets::Stack
  class Resource
    module Dsl
      extend ActiveSupport::Concern

      def resources
        Resource.definitions
      end

      included do
        class << self
          def resource(*definition)
            Resource.new(*definition).register
          end
        end
      end
    end
  end
end
